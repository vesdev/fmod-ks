const fmod = import "../../src/_lib.ks";

fmod.run(1, (system) => (
	let master = fmod.Bank.load(system, "./examples/assets/Master.bank");
	let strings = fmod.Bank.load(system, "./examples/assets/Master.strings.bank");
));
