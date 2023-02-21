# Lenti-STARR

## Software Requirements
- Ubuntu/macOS
- [MACS2](https://pypi.org/project/MACS2/)
- [bedtools](https://github.com/arq5x/bedtools2)
- [R](https://www.r-project.org/)
- [R package fitdistrplus](https://cran.r-project.org/web/packages/fitdistrplus/index.html)

## Running instructions
1. Place sorted and indexec BAM files into the folder `folder_X` and `folder_Y`
2. Run `process.sh` script as shown below
   ```bash
   process.sh folder_X folder_Y
   ```
3. Check outputs in the current directory

## Running instructions using Docker container
1. Place sorted and indexec BAM files into the folder `folder_X` and `folder_Y`, create a separate folder for outputs `outputs`
2. Start docker container mounting `folder_X`, `folder_Y`, and `outputs` folders as shown below
   ```bash
   docker run --rm -ti -v folder_X:/tmp/folder_X folder_Y:/tmp/folder_Y 
   outputs:/tmp/outputs biowardrobe2/starr:v0.0.1 "cd /tmp/outputs && process.sh /tmp/folder_X /tmp/folder_Y"
   ```