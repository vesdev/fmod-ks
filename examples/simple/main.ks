const fmod = import "../../src/_lib.ks";

let options =  {
	.max_channels = 512,
	.handedness = :Right,
	.up = { 0, 1, 0 },
	.forward = { 0, 0, -1 },
};

fmod.run(
	options,
	(system) => (
		let master = fmod.bank.load(system, "./assets/Build/Desktop/Master.bank");
		let strings = fmod.bank.load(system, "./assets/Build/Desktop/Master.strings.bank");

		# you should generally use GUID's instead
		fmod.event.play(system, "event:/meow");

		while true do (
			fmod.system.update(system);

			# 16ms
			std.thread.sleep_ns(16 * 1000000);
		);
	),
);
