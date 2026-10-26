use std.target.c.*;

module:

const system = import "./system.ks";
const bank = import "./bank.ks";
const event = import "./event.ks";

use system.System;
use system.Options;

const includes = () => (
	@native "#include <fmod_studio.h>";
	@native "#include <fmod_errors.h>";
);

const init = (options :: Options) -> System => (
	includes();

	let handle = system._create();
	system._initialize(handle, options);

	{
		.handle,
		.up = options.up,
		.forward = options.forward,
	}
);

const drop = (sys :: System) => (
	system._release(sys.handle);
);
