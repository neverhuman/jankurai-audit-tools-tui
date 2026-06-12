//! Property tests for the deterministic input-encoding surface.
//!
//! `crates/tuiwright/src/input.rs` turns high-level `Key`/`MouseButton` events
//! into the raw byte sequences a terminal application would receive. Those
//! functions are pure, so we can check their invariants over a wide range of
//! generated inputs with `proptest` instead of a handful of hand-picked cases.

use proptest::prelude::*;
use tuiwright::input::{
    encode_key, encode_paste, encode_sgr_mouse, encode_sgr_scroll, encode_text,
};
use tuiwright::{Key, MouseButton};

prop_compose! {
    fn any_mouse_button()(idx in 0u8..5) -> MouseButton {
        match idx {
            0 => MouseButton::Left,
            1 => MouseButton::Middle,
            2 => MouseButton::Right,
            3 => MouseButton::WheelUp,
            _ => MouseButton::WheelDown,
        }
    }
}

proptest! {
    /// A printable character key encodes to exactly that character's UTF-8 bytes,
    /// regardless of application-cursor mode.
    #[test]
    fn char_key_round_trips(c in proptest::char::range('\u{20}', '\u{7e}'), app in any::<bool>()) {
        let bytes = encode_key(Key::Char(c), app);
        prop_assert_eq!(bytes, c.to_string().into_bytes());
    }

    /// `encode_text` is exactly the UTF-8 bytes of the input string.
    #[test]
    fn text_is_utf8_bytes(s in ".{0,64}") {
        prop_assert_eq!(encode_text(&s), s.as_bytes().to_vec());
    }

    /// Bracketed paste wraps the payload in the start/end markers and preserves
    /// the original bytes in between; non-bracketed paste is just the raw text.
    #[test]
    fn bracketed_paste_wraps_payload(s in ".{0,64}") {
        let wrapped = encode_paste(&s, true);
        prop_assert!(wrapped.starts_with(b"\x1b[200~"));
        prop_assert!(wrapped.ends_with(b"\x1b[201~"));
        let inner = &wrapped[6..wrapped.len() - 6];
        prop_assert_eq!(inner, s.as_bytes());

        prop_assert_eq!(encode_paste(&s, false), encode_text(&s));
    }

    /// Arrow keys differ between normal and application-cursor mode and are never
    /// empty in either mode.
    #[test]
    fn arrow_keys_depend_on_mode(idx in 0u8..4) {
        let key = match idx {
            0 => Key::Up,
            1 => Key::Down,
            2 => Key::Left,
            _ => Key::Right,
        };
        let normal = encode_key(key, false);
        let application = encode_key(key, true);
        prop_assert!(!normal.is_empty());
        prop_assert!(!application.is_empty());
        prop_assert_ne!(normal, application);
    }

    /// An SGR 1006 mouse event is a well-formed CSI sequence whose 1-based
    /// coordinates are the 0-based input plus one (saturating).
    #[test]
    fn sgr_mouse_is_one_based(
        button in any_mouse_button(),
        col in any::<u16>(),
        row in any::<u16>(),
        release in any::<bool>(),
    ) {
        let bytes = encode_sgr_mouse(button, col, row, release);
        prop_assert!(bytes.starts_with(b"\x1b[<"));
        let last = *bytes.last().unwrap();
        prop_assert!(last == b'M' || last == b'm');

        let body = std::str::from_utf8(&bytes[3..bytes.len() - 1]).unwrap();
        let parts: Vec<&str> = body.split(';').collect();
        prop_assert_eq!(parts.len(), 3);
        prop_assert_eq!(parts[1].parse::<u32>().unwrap(), col.saturating_add(1) as u32);
        prop_assert_eq!(parts[2].parse::<u32>().unwrap(), row.saturating_add(1) as u32);
    }

    /// A scroll event emits at least one wheel report and at most `|lines|` of
    /// them (clamped to one), each a CSI sequence ending in `M`.
    #[test]
    fn sgr_scroll_emits_per_line(col in any::<u16>(), row in any::<u16>(), lines in -8i16..8) {
        let bytes = encode_sgr_scroll(col, row, lines);
        let expected = lines.unsigned_abs().max(1) as usize;
        let reports = bytes.windows(3).filter(|w| *w == b"\x1b[<").count();
        prop_assert_eq!(reports, expected);
        prop_assert!(bytes.ends_with(b"M"));
    }
}
