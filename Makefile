.PHONY: zip_scripts
zip_scripts:
	zip -j terraform/modules/s3_objects/files/cv2_lambda_function.zip scripts/cv2_lambda_function.py
	zip -j terraform/modules/s3_objects/files/lifx_lambda_function.zip scripts/lifx_lambda_function.py

.PHONY: build_opencv
build_opencv: clean
	cp terraform/build_opencv.tf ./
	cp -R terraform/modules ./
	terraform init
	terraform apply -state=./state/opencv.tfstate

.PHONY: destroy_opencv
destroy_opencv: clean
	cp terraform/build_opencv.tf ./
	cp -R terraform/modules ./
	terraform init
	terraform destroy -state=./state/opencv.tfstate

.PHONY: build_lambda
build_lambda: clean zip_scripts
	cp terraform/build_lambda.tf ./
	cp -R terraform/modules ./
	terraform init
	terraform apply -state=./state/lambda.tfstate

.PHONY: destroy_lambda
destroy_lambda: clean
	cp terraform/build_lambda.tf ./
	cp -R terraform/modules ./
	terraform init
	terraform destroy -state=./state/lambda.tfstate

.PHONY: clean
clean:
	-@rm -rf modules/
	-@rm -rf .terraform/
	-@rm *.tf
	-@rm terraform/modules/s3_objects/files/cv2_lambda_function.zip
	-@rm terraform/modules/s3_objects/files/lifx_lambda_function.zip

.PHONY: clean-all
clean-all: clean
	-@rm terraform.tfstate*
