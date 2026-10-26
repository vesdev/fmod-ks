use (import "./system.ks").*;
use (import "./error.ks").*;
use std.target.c.*;

module:

const Bank = @opaque_type "FMOD_STUDIO_BANK*";

const load = (system :: System, path :: &str) -> Bank => (
	let path = C_String.from_str(path);
	let mut bank :: Bank = @native "NULL"; 

	let result :: Result = @native ''FMOD_Studio_System_LoadBankFile(
    	\(system.handle),
    	\(path),
    	FMOD_STUDIO_LOAD_BANK_NORMAL,
    	\(&mut bank)
	)'';


	C_String.drop(path);

	check(
		result,
    	"bank.load",
	);

	bank
);
