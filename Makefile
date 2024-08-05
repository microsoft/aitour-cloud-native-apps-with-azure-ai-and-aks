# run a script
setup:
	@./train-the-trainer/demo/setup-demo.sh;

run:
	@cd train-the-trainer/demo && ./run-demo.sh;

clean:
	@cd src/infra/terraform && terraform destroy --auto-approve;