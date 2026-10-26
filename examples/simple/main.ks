const fmod = import "../../src/_lib.ks";

let options =  {
	.max_channels = 512,
	.handedness = :Right,
	.up = { 0, 1, 0 },
	.forward = { 0, 0, -1 },
};

let sys = fmod.init(options);
@defer fmod.drop(sys);

let master = fmod.bank.load(sys, "./assets/Build/Desktop/Master.bank");
let strings = fmod.bank.load(sys, "./assets/Build/Desktop/Master.strings.bank");

# you should generally use GUID's instead
fmod.event.play(sys, "event:/meow");

while true do (
	fmod.system.update(sys);

	# 16ms
	std.thread.sleep_ns(16 * 1000000);
);
