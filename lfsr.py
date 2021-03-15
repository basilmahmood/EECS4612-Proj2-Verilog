class lfsr:
    def __init__(self, size, tap_locations):
        self.size = size
        self.tap_locations = tap_locations
        self.lfsr_list = []

        # Initialize list representation of lfsr as 0
        for i in range(size):
            self.lfsr_list.append(0)

    def shift(self):
        new_lfsr_list = []
        for i in range(self.size):
            new_lfsr_list.append(0)

        for i, _ in enumerate(self.lfsr_list):
            if ((i-1) in self.tap_locations or ((i == 0) and (self.size-1 in self.tap_locations))): # if theres a tap
                new_lfsr_list[i] = self.lfsr_list[i-1] ^ self.lfsr_list[-1]
            else:
                new_lfsr_list[i] = self.lfsr_list[i-1]

        self.lfsr_list = new_lfsr_list

    def input_seed(self, seed):
        for i, _ in enumerate(seed):
            self.lfsr_list[i] = int(seed[i], 2)

    def generate(self, number):
        random_numbers = []
        for i in range(number):
            random_number = ""

            # Shift by a full cycle to generate new random number
            for j in range(self.size):
                self.shift()

            random_number = ''.join([str(elem) for elem in reversed(self.lfsr_list)]) 
            random_numbers.append(random_number)
        
        return random_numbers