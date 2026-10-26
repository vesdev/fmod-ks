use (import "./error.ks").*;
use std.target.c.*;

module:

const System = @opaque_type "FMOD_STUDIO_SYSTEM*";

# internal
const _create = () -> System => (
	let mut system :: System = @native "NULL";

	check(
		@native "FMOD_Studio_System_Create(\(&mut system), FMOD_VERSION)",
		"system.create"
	);

	system
);

const _release = (system :: System) => (
    check(
        @native "FMOD_Studio_System_Release(\(system))",
        "system.release",
    );
);

const _initialize = (system :: System, max_channels :: Int32) => (
	check(
		@native ''FMOD_Studio_System_Initialize(
	    	\(system),
	    	\(max_channels),
	    	FMOD_STUDIO_INIT_NORMAL,
	    	FMOD_INIT_NORMAL,
	    	NULL
		)'',
    	"system.initialize",
	);
);

# public api
const update = (system :: System) => (
    check(
        @native "FMOD_Studio_System_Update(\(system))",
        "system.update",
    );
);
