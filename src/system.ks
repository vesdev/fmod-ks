use (import "./error.ks").*;
use std.target.c.*;

module:

const Handle = @opaque_type "FMOD_STUDIO_SYSTEM*";

const Handedness = newtype (
	| :Left
	| :Right
);

const Options = newtype {
	.max_channels :: Int32,
	.handedness :: Handedness,
	.up :: { Float32, Float32, Float32 },
	.forward :: { Float32, Float32, Float32 },
};

const System = newtype {
	.handle :: Handle,
	.up :: { Float32, Float32, Float32 },
	.forward :: { Float32, Float32, Float32 },
};

# internal
const _create = () -> Handle => (
	let mut handle :: Handle = @native "NULL";

	check(
		@native "FMOD_Studio_System_Create(\(&mut handle), FMOD_VERSION)",
		"system.create"
	);

	handle
);

const _release = (handle :: Handle) => (
    check(
        @native "FMOD_Studio_System_Release(\(handle))",
        "system.release",
    );
);

const _init_flags = (handedness :: Handedness) -> @opaque_type "FMOD_INITFLAGS" => (
	match handedness with (
		| :Left => @native "FMOD_INIT_NORMAL"
		| :Right => @native "FMOD_INIT_NORMAL | FMOD_INIT_3D_RIGHTHANDED"
	)
);

const _initialize = (handle :: Handle, options :: Options) => (
	let flags = _init_flags(options.handedness);

	check(
		@native ''FMOD_Studio_System_Initialize(
	    	\(handle),
	    	\(options.max_channels),
	    	FMOD_STUDIO_INIT_NORMAL,
	    	\(flags),
	    	NULL
		)'',
    	"system.initialize",
	);
);

# public api
const update = (system :: System) => (
    check(
        @native "FMOD_Studio_System_Update(\(system.handle))",
        "system.update",
    );
);

# TODO: multiple listeners
const set_listener = (
	system :: System,
	position :: { Float32, Float32, Float32 },
	forward :: { Float32, Float32, Float32 },
	up :: { Float32, Float32, Float32 },
) => (
	let { px, py, pz } = position;
	let { fx, fy, fz } = forward;
	let { ux, uy, uz } = up;
	
	let mut attributes :: @opaque_type "FMOD_3D_ATTRIBUTES" = @native ''(FMOD_3D_ATTRIBUTES) {
		.position = { \(px), \(py), \(pz) },
		.forward = { \(fx), \(fy), \(fz) },
		.up = { \(ux), \(uy), \(uz) },
	}'';
		
	let result :: Result = @native ''FMOD_Studio_System_SetListenerAttributes(
		\(system.handle),
		0,
		\(&mut attributes),
		NULL
	)'';

	check(
		result,
		"system.set_listener",
	);
);
