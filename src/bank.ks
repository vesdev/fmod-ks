use (import "./system.ks").*;
use (import "./error.ks").*;
use std.target.c.*;

module:

const Bank = @opaque_type "FMOD_STUDIO_BANK*";

const _is_emscripten = () -> Bool => @native ''
    #ifdef __EMSCRIPTEN__
        true
    #else
        false
    #endif
'';

# load whole bank into ram
const _load_memory = (system :: System, path :: C_String, bank :: &mut Bank) -> Result => (
	@native "#include <stdio.h>";
	@native "#include <stdlib.h>";

	@native ''({
		FMOD_RESULT result = FMOD_ERR_FILE_NOTFOUND;
		FILE *file = fopen(\(path), "rb");

		if (file) {

			fseek(file, 0, SEEK_END);
			long length = ftell(file);

			fseek(file, 0, SEEK_SET);
			char *buffer = malloc(length);

			result = FMOD_ERR_MEMORY;

			if (buffer) {
				fread(buffer, 1, length, file);

				result = FMOD_Studio_System_LoadBankMemory(
					\(system.handle),
					buffer,
					(int) length,
					FMOD_STUDIO_LOAD_MEMORY,
					FMOD_STUDIO_LOAD_BANK_NORMAL,
					\(bank)
				);

				free(buffer);
			}

			fclose(file);
		}

		result;
	})''
);

const load = (system :: System, path :: &str) -> Bank => (
	let mut bank :: Bank = @native "NULL";

	let result :: Result = (
		let path = C_String.from_str(path);
		@defer C_String.drop(path);

		if _is_emscripten() then (
			_load_memory(system, path, &mut bank)
		) else (
			# load from filename doesnt work on web
			@native ''FMOD_Studio_System_LoadBankFile(
				\(system.handle),
				\(path),
				FMOD_STUDIO_LOAD_BANK_NORMAL,
				\(&mut bank)
			)''
		)
	);

	check(
		result,
		"bank.load",
	);

	bank
);
