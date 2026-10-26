use std.target.c.*;

module:

const system = import "./system.ks";
const bank = import "./bank.ks";
const event = import "./event.ks";

use system.System;


const includes = () => (
	@native "#include <fmod_studio.h>";
	@native "#include <fmod_errors.h>";
);

const run = (max_channels :: Int32, f :: System -> ()) => (
	includes();
	
	let sys = system._create();
	system._initialize(sys, max_channels);

	f(sys);
	
	system._release(sys);	
);
