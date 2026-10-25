use std.target.c.*;

module:

const Result = @opaque_type "FMOD_RESULT";

const includes = () => (
	@native "#include <fmod_studio.h>";
	@native "#include <fmod_errors.h>";
);

const check = (result :: Result, fn_name :: &str) => (
	includes();

	if @native "\(result) != FMOD_OK" then (
		let msg = C_str.to_String(@native "FMOD_ErrorString(\(result))");
		panic_fmt!("\(fn_name) failed: \(msg)");
	)
);
