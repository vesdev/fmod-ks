const fmod = import "../../src/_lib.ks";
const common = import "../common.ks";

let options =  {
	.max_channels = 512,
	.handedness = :Right,
	.up = { 0, 1, 0 },
	.forward = { 0, 0, -1 },
};

# -- init fmod system --
let sys = fmod.init(options);
@defer fmod.drop(sys);

# -- loading banks --
let master = fmod.bank.load(sys, "./assets/Build/Desktop/Master.bank");
let strings = fmod.bank.load(sys, "./assets/Build/Desktop/Master.strings.bank");

# -- setting bus volume --
let bus = fmod.bus.get(sys, "bus:/");
fmod.bus.set_volume(bus, 0.5);

while true do (
	# -- playing events --
	# you should generally prefer GUID's instead
	fmod.event.play(sys, "event:/meow");

	fmod.system.update(sys);

	common.sleep_ms(512);
);
