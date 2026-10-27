module:

const sleep_ms = (ms :: Int32) => (
	@native ''
#ifdef __EMSCRIPTEN__
	({ void emscripten_sleep(unsigned int ms); emscripten_sleep(\(ms)); })
#else
	Kast_sleep_ns((Int64) \(ms) * 1000000)
#endif
	'';
);
