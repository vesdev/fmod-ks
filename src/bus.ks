use (import "./system.ks").*;
use (import "./error.ks").*;
use (import "./event.ks").*;
use std.target.c.*;

module:

const Bus = @opaque_type "FMOD_STUDIO_BUS*";

# id can be a path or GUID, "bus:/" is the master bus
const get = (system :: System, id :: &str) -> Bus => (

	let mut bus :: Bus = @native "NULL";

	let result :: Result = (
		let id = C_String.from_str(id);
		@defer C_String.drop(id);

		@native ''FMOD_Studio_System_GetBus(
			\(system.handle),
			\(id),
			\(&mut bus)
		)''
	);
	
	check(
		result,
		"bus.get",
	);

	bus
);

const set_volume = (bus :: Bus, volume :: Float32) => (
	let result :: Result = @native ''FMOD_Studio_Bus_SetVolume(
		\(bus),
		\(volume)
	)'';
	
	check(
		result,
		"bus.set_volume",
	);
);

const get_volume = (bus :: Bus) -> Float32 => (
	let mut volume :: Float32 = 0;

	let result :: Result = @native ''FMOD_Studio_Bus_GetVolume(
		\(bus),
		\(&mut volume),
		NULL
	)'';
	
	check(
		result,
		"bus.get_volume",
	);

	volume
);

const set_paused = (bus :: Bus, paused :: Bool) => (
	let result :: Result = @native ''FMOD_Studio_Bus_SetPaused(
		\(bus),
		\(paused) ? 1 : 0
	)'';

	check(
		result,
		"bus.set_paused",
	);
);

const set_mute = (bus :: Bus, mute :: Bool) => (

	let result :: Result = @native ''FMOD_Studio_Bus_SetMute(
		\(bus),
		\(mute) ? 1 : 0
	)'';

	check(
		result,
		"bus.set_mute",
	);
);

const stop_all_events = (bus :: Bus, fadeout :: Fadeout) => (
	let c_mode = _stop_mode(fadeout);

	let result :: Result = @native ''FMOD_Studio_Bus_StopAllEvents(
		\(bus),
		\(c_mode)
	)'';

	check(
		result,
		"bus.stop_all_events",
	);
);
