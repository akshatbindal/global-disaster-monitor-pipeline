from setuptools import setup, find_packages

setup(
    name="disaster-pipeline",
    version="1.0.0",
    packages=find_packages(),
    install_requires=[
        "apache-beam[gcp]==2.*",
        "google-cloud-bigquery==3.*",
        "google-cloud-aiplatform==1.*",
        "requests==2.*"
    ],
    python_requires=">=3.8",
) 