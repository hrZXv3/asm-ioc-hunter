ASM     = nasm
ASFLAGS = -f elf64 -g -F dwarf
LD      = ld

BIN = ioc-hunter
SRC = src/ioc-hunter.asm
OBJ = build/ioc-hunter.o

all: $(BIN)

$(OBJ): $(SRC)
	@mkdir -p build
	$(ASM) $(ASFLAGS) $< -o $@

$(BIN): $(OBJ)
	$(LD) $< -o $@

demo: $(BIN)
	./$(BIN) scan samples/incident.log
	@echo
	./$(BIN) xor samples/payload.bin | strings -n 8

test: $(BIN)
	bash tests/run_tests.sh

clean:
	rm -rf build $(BIN)

.PHONY: all demo test clean
