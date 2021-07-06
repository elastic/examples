from setuptools import setup, find_packages

setup(
    name='metrics',
    version='0.1.0',
    python_requires=">=3.7.0",
    packages=find_packages(exclude=('tests', 'docs')),
)
