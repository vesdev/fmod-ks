const fmod = import "../../src/_lib.ks";

fmod.run(1, (system) => (
	let master = fmod.Bank.load(system, "./assets/Build/Desktop/Master.bank");
	let strings = fmod.Bank.load(system, "./assets/Build/Desktop/Master.strings.bank");
));
