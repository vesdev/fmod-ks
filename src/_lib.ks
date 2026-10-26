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

const run = (options :: Options, f :: System -> ()) => (
	includes();

	let handle = system._create();
	system._initialize(handle, options);

	f({
		.handle,
		.up = options.up,
		.forward = options.forward,
	});

	system._release(handle);
);
