# run a script
setup:
	@./session-delivery-resources/demo/setup.sh;

run:
	@cd ./session-delivery-resources/demo && ./demo.sh;

reset:
	@./session-delivery-resources/demo/reset.sh;

cleanup:
	@./session-delivery-resources/demo/cleanup.sh;