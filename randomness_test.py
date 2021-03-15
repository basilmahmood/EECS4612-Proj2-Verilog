### Modified from https://www.geeksforgeeks.org/runs-test-of-randomness-in-python/ ###
### Read the above webpage for more info on this type of randomness test ###

from lfsr import lfsr
import statistics
import math

def random_test(l, l_median):

    runs, n1, n2 = 0, 0, 0

    # Checking for start of new run
    for i in range(len(l)):

        # no. of runs
        if (l[i] >= l_median and l[i-1] < l_median) or \
                (l[i] < l_median and l[i-1] >= l_median):
            runs += 1

        # no. of positive values
        if(l[i]) >= l_median:
            n1 += 1

        # no. of negative values
        else:
            n2 += 1

    runs_exp = ((2*n1*n2)/(n1+n2))+1
    stan_dev = math.sqrt((2*n1*n2*(2*n1*n2-n1-n2)) /
                         (((n1+n2)**2)*(n1+n2-1)))

    z = (runs-runs_exp)/stan_dev

    return z

test_lfsr = lfsr(26, [0, 1, 5, 25])
test_lfsr.input_seed('1')
random_numbers_str = test_lfsr.generate(10000)
random_numbers = []

for random_number_str in random_numbers_str:
    random_numbers.append(int(random_number_str, 2))

median = (2**test_lfsr.size - 1)/2
Z = random_test(random_numbers, median)

Zcritical = 1.96
print('Z-statistic =', abs(Z))
print(f"The test { 'Passed' if (abs(Z) < Zcritical) else 'Failed'}") # Should be less than Zcritical for test to pass
