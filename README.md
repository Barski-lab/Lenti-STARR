# Lenti-STARR

## Software Requirements
- Ubuntu/macOS
- [MACS2](https://pypi.org/project/MACS2/)
- [bedtools](https://github.com/arq5x/bedtools2)
- [R with installed fitdistrplus package](https://cran.r-project.org/web/packages/fitdistrplus/index.html)

## Running from command line
1. Clone Lenti-STARR GitHub repository
   ```bash
   git clone https://github.com/Barski-lab/Lenti-STARR.git
   ```
2. Place sorted and indexed BAM files into two separate folders - `folder_A` and `folder_B`
3. Create a folder for output files
   ```bash
   mkdir results
   ```
4. Run `process.sh` script from the Lenti-STARR repository in the folder where you want the outputs to be saved (a.k.a `results`)
   ```bash
   cd /absolute/path/to/results
   /absolute/path/to/Lenti-STARR/process.sh /absolute/path/to/folder_A /absolute/path/to/folder_B
   ```
5. See outputs saved in the `results` directory

## Using Docker container
1. Clone Lenti-STARR GitHub repository
   ```bash
   git clone https://github.com/Barski-lab/Lenti-STARR.git
   ```
2. Place sorted and indexed BAM files into two separate folders - `folder_A` and `folder_B`
3. Create a folder for output files
   ```bash
   mkdir results
   ```
4. Start `process.sh` script from the docker container mounting `folder_A`, `folder_B`, and `results` folders as shown below
   ```bash
   docker run --rm -ti -w /tmp/results -v /absolute/path/to/folder_A:/tmp/folder_A -v /absolute/path/to/folder_B:/tmp/folder_B -v /absolute/path/to/results:/tmp/results biowardrobe2/starr:v0.0.1 process.sh /tmp/folder_A /tmp/folder_B
   ```
5. See outputs saved in the `results` directory


**Notes:**
- `/absolute/path/to` should be replaced with the real locations on your file system