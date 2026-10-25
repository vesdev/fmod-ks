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
		panic_fmt!("fmod-ks \(fn_name) failed: \(msg)");
	)
);

const System = @opaque_type "FMOD_STUDIO_SYSTEM*";

impl System as module = (
	module:

	const _create = () -> System => (
		let mut system :: System = @native "NULL";
		
		check(
			@native "FMOD_Studio_System_Create(\(&mut system), FMOD_VERSION)",
			"System.create"
		);

		system
	);

	const _release = (system :: System) => (
	    check(
	        @native "FMOD_Studio_System_Release(\(system))",
	        "System.release",
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
        	"System.initialize",
    	);
	);

);

const Bank = @opaque_type "FMOD_STUDIO_BANK*";

impl Bank as module = (
	module:

	const load = (system :: System, path :: &str) -> Bank => (
		let path = C_String.from_str(path);
		let mut bank :: Bank = @native "NULL"; 

    	check(
    		@native ''FMOD_Studio_System_LoadBankFile(
            	\(system),
            	\(path),
            	FMOD_STUDIO_LOAD_BANK_NORMAL,
            	\(&mut bank)
        	)'',
        	"Bank.load",
    	);


		C_String.drop(path);

		bank
	);
);

const run = (max_channels :: Int32, f :: System -> ()) => (
	let system = System._create();
	System._initialize(system, max_channels);

	f(system);
	
	System._release(system);	
);

