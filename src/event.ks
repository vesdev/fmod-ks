use (import "./error.ks").*;
use (import "./system.ks").*;
use std.target.c.*;

module:

const EventDescription = @opaque_type "FMOD_STUDIO_EVENTDESCRIPTION*";
const EventInstance = @opaque_type "FMOD_STUDIO_EVENTINSTANCE*";

const Fadeout = newtype (
	| :Allow
	| :Immediate	
);

# id can be a path or GUID
const get = (system :: System, id :: &str) -> EventDescription => (
	let id = C_String.from_str(id);
	let mut desc :: EventDescription = @native "NULL"; 

	let result :: Result = @native ''FMOD_Studio_System_GetEvent(
    	\(system),
    	\(id),
    	\(&mut desc)
	)'';


	C_String.drop(id);

	check(
		result,
    	"event.get",
	);

	desc
);

const create_instance = (description :: EventDescription) -> EventInstance => (
	let mut instance :: EventInstance = @native "NULL"; 

	let result :: Result = @native ''FMOD_Studio_EventDescription_CreateInstance(
    	\(description),
    	\(&mut instance)
	)'';

	check(
		result,
    	"event.create_instance",
	);

	instance
);

const start = (instance :: EventInstance) => (	
	let result :: Result = @native ''FMOD_Studio_EventInstance_Start(
    	\(instance)
	)'';

	check(
		result,
    	"event.start",
	);
);

const release = (instance :: EventInstance) => (	
	let result :: Result = @native ''FMOD_Studio_EventInstance_Release(
    	\(instance)
	)'';

	check(
		result,
    	"event.release",
	);
);

const play = (system :: System, id :: &str) => (
	let desc = get(system, id);
	let instance = create_instance(desc);

	start(instance);
	release(instance);
);

const _stop_mode = (fadeout :: Fadeout) -> @opaque_type "FMOD_STUDIO_STOP_MODE" => (
	match fadeout with (
		| :Allow => @native "FMOD_STUDIO_STOP_ALLOWFADEOUT"
		| :Immediate => @native "FMOD_STUDIO_STOP_IMMEDIATE"
	)
);

const stop = (instance :: EventInstance, fadeout :: Fadeout) => (
	let c_mode = _stop_mode(fadeout);

	let result :: Result = @native ''FMOD_Studio_EventInstance_Stop(
    	\(instance),
		\(c_mode)
	)'';

	check(
		result,
    	"event.stop",
	);
);

const set_parameter = (instance :: EventInstance, name :: &str, value :: Float32) => (
	let name = C_String.from_str(name);
	
	let result :: Result = @native ''FMOD_Studio_EventInstance_SetParameterByName(
		\(instance),
		\(name),
		\(value),
		0
	)'';

	C_String.drop(name);

	check(
		result,
		"event.set_parameter",
	);
);

const set_label = (instance :: EventInstance, name :: &str, label :: &str) => (
	let name = C_String.from_str(name);
	let label = C_String.from_str(label);

	let result :: Result = @native ''FMOD_Studio_EventInstance_SetParameterByNameWithLabel(
		\(instance),
		\(name), 
		\(label),
		0
	)'';

	C_String.drop(name);
	C_String.drop(label);

	check(
		result,
		"event.set_label",
	);
);

const is_stopped = (instance :: EventInstance) -> Bool => with_return (
	let mut state :: @opaque_type "FMOD_STUDIO_PLAYBACK_STATE" = @native "FMOD_STUDIO_PLAYBACK_STOPPED";
	
	let result :: Result = @native ''FMOD_Studio_EventInstance_GetPlaybackState(
    	\(instance),
    	\(&mut state)
	)'';

	if @native "\(result) == FMOD_ERR_INVALID_HANDLE" then (
    	return true;
	);

	check(
		result,
    	"event.is_stopped",
	);

	@native "\(state) == FMOD_STUDIO_PLAYBACK_STOPPED" 
);
