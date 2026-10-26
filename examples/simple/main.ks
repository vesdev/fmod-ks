const fmod = import "../../src/_lib.ks";

fmod.run(512, (system) => (
	let master = fmod.bank.load(system, "./assets/Build/Desktop/Master.bank");
	let strings = fmod.bank.load(system, "./assets/Build/Desktop/Master.strings.bank");

	# you should generally use GUID's instead
	fmod.event.play(system, "event:/meow");
	
	while true do (
		fmod.system.update(system);

		# 16ms
		std.thread.sleep_ns(16 * 1000000);
	);
));
