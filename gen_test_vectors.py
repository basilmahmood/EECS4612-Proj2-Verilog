from lfsr import lfsr

test_lfsr = lfsr(26, [0, 1, 5, 25])
test_lfsr.input_seed('1')
random_numbers = test_lfsr.generate(1000)


