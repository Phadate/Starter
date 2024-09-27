# STEP BY STEP PROCESS TO SETUP END TO END MACHINE LEARNING PREOJECT

Set up project with Github

1. Data Ingestion
2. Data Transformation
3. Model trainer
4. Model Evaluation
5. Model deployment

CI/CD Pipelines - Github Actions
Deployment- AWS

## Setting up project with Github {Repository}

- set up new environment
- setup.py
- requirements.txt

- first create new repository on github
- set on public and give it your project's name
- create a project with the same name of your repository on your computer
- open conda/micromamba prompt
- write `code .`

### How to create an environment that hold a project

- first create a new environment on your local environment. you can decide to use conda/ micromamba docummentation to create this
- sample env creation is `conda create -p env_name name_of_packages`
- To activate the env, use `conda activate env_name`

### How to sync github repo with local folder

- open command prompt in vscode and enter `git init`
- create a README.md file in vscode
- to add to github repo, use `git add README.md`
- to commit, `git commit -m "First commit"`
- check status `git status`
- check branch with `git branch -M main`
- to link with github, `git remote add origin git_hub_repo_url`
- check remote status with `git remote -v`
- to push to github from local folder, use `git push -u origin main`
- if you are performing this for the first time, please set the `git config--global` for username and email

### Creating a .gitignore file

What is a .gitignore file ?
A .gitignore file is a text file that tells Git, a version control system, which files or directories to ignore when tracking changes in a project. It’s a way to specify which files or patterns of files should not be included in the repository or tracked by Git.

- on github repo, create a new file called .gitignore and choose a template for pthon code
- add commit message and make changes
- you can pull this to your local file by clicking `git pull`

### Working with setup.py and requirements.txt file.

**Setup.py** - setup.py is a Python script that serves as the configuration file for packaging and distributing Python projects using the setuptools library. It’s a crucial file in a Python project, providing metadata and instructions for building, installing, and distributing the project.

**Requirement.txt** - Requirements.txt (also known as requirements.txt) is a text file used in Python projects to manage dependencies, specifically listing the required Python packages and their versions

- In our project folder, create a setup.py and requirement.txt

Below code goes in your setup.py

~~~py
    from setuptools import find_packages, setup
    from typing import List


    HYPEN_E_DOT='-e .'
    def get_requirements(file_path:str)->List[str]:
        '''
        this function will return the list of requirements

        '''
        requirements=[]
        with open(file_path) as file_obj:
            requirements=file_obj.readlines()
            requirements=[req.replace("\n","") for req in requirements]

            if HYPEN_E_DOT in requirements:
                requirements.remove(HYPEN_E_DOT)

        
        return requirements


    setup(
    name='Your Project Name',
    version='1.0',
    author='Your Name',
    author_email='your.email@example.com',
    description='A brief description of your project',
    long_description=open('README.md').read(),  # Use README.md or README.txt
    long_description_content_type='text/markdown',
    url='https://github.com/your-username/your-project',  # Your project's URL
    license='MIT',  # Choose a license from the Python Software Foundation
    packages=find_packages(),  # List of packages to include
    install_requires=get_requirements('requirement.txt'),  # Dependencies (optional)
    classifiers=[],  # Optional classification metadata)

    )
~~~

- In your requirements.txt file, list your package

'''
    pandas
    numpy
    seaborn
    matplotlib
    -e .
'''

- open terminal `pip install -r requirements.txt`
- `git add`,  `git commit -m "commit_message` and `git push -u origin main`

### Setting up the src folder

- Create a new folder `src` as a package
- in this folder, add `__init__.py` file  *This find_packages() created in the setup.py will automatically find the `__init__` in any folder it is created*
- create a **component** folder and create `__init__.py` in the new folder. also we will add a *data_ingestion.py*, *data_transformation.py*, *model_trainer.py*
- create another **Pipline** folder with *train_pipeline.py*, *predict_pipeline.py* and `__init__.py` created in it
- create following file in the **SRC** - *exeption.py*, *logger.py*, and *utils.py*

In the exception.py, we are going to write the exception code below

~~~py
    import sys

    def error_message_detail(error,error_detail:sys):
        _,_,exc_tb=error_details=.exc_info()
        file_name=exc_tb.tb_frame.f_code.co_filename
        error_message="Error occured in python script name[{0}] line number [{1}] error message [{2}].format()
         file_name,exc_tb.tb_lineno,str(error)


        return error_message 


    class CustomException(Exception):
        def __init__(self,error_message, error_detail:sys):
            super.__Init__(error_message)
            self.error_message=error_message_detail(error_message,error_detail=error_detail)

        def __str__(self):
            return self.error_message

~~~

In the logger.py, we write following

~~~py
    import logging
    import os
    from datetime import datetime 

    LOG_FILE=f"{datetime.now().strftime('%m_%d_%Y_%H_%M_%S')}.log"
    logs_path=os.path.join(os.getcwd(), "logs", LOG_FILE)
    os.makedirs(logs_path,exist_ok=True)

    LOG_FILE_PATH=os.path.join(logs_path,LOG_FILE)

    logging.basicConfig(
        filename=LOG_FILE_PATH,
        format= "[%(asctime)s ] %(limeno)d %(name)s -%(levelname)s - %(message)s",
        level=logging.INFO,
    )


    if __name__="__main__":
        logging.INFO("Logging has started")