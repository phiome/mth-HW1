SV_FILES = ${wildcard ./src/pkg/*.sv} ${wildcard ./src/*.sv}
TB_FILES = ${wildcard ./tb/*.sv}
ALL_FILES = ${SV_FILES} ${TB_FILES}


lint:
	@echo "Running lint checks..."
	verilator --lint-only --timing -Wall ${SV_FILES}

build:
	verilator --binary $(SV_FILES) ./tb/tb_decoder.sv --top tb_decoder -j 0 --trace-fst --trace-structs -Wno-UNUSED -Wno-WIDTHEXPAND --assert

run: build
	obj_dir/Vtb_decoder

wave: run
	gtkwave dump.fst

clean:
	@echo "Cleaning temp files..."
	rm dump.fst
	rm obj_dir/*


.PHONY: compile run wave lint clean help
