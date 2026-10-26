use std.target.c.*;

module:

const Result = @opaque_type "FMOD_RESULT";

const check = (result :: Result, fn_name :: &str) => (
	if @native "\(result) != FMOD_OK" then (
		let msg = C_str.to_String(@native "FMOD_ErrorString(\(result))");
		panic_fmt!("fmod-ks \(fn_name) failed: \(msg)");
	)
);
