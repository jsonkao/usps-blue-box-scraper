ZIP_FILE := New_York_State_ZIP_Codes-County_FIPS_Cross-Reference.csv
ZIP_CODES := $(shell cat $(ZIP_FILE) | cut -d ',' -f 5)

# Set number of parallel jobs to number of available processors
NPROCS = $(shell sysctl hw.ncpu | grep -o '[0-9]\+')
MAKEFLAGS += -j$(NPROCS)

all: $(addsuffix .json,$(ZIP_CODES))

%.json:
	time curl 'https://tools.usps.com/UspsToolsRestServices/rest/POLocator/findLocations' \
  -H 'authority: tools.usps.com' \
  -H 'accept: application/json, text/javascript, */*; q=0.01' \
  -H 'x-requested-with: XMLHttpRequest' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36' \
  -H 'content-type: application/json;charset=UTF-8' \
  -H 'origin: https://tools.usps.com' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-dest: empty' \
  -H 'accept-language: en-US,en;q=0.9' \
  --data-binary '{"requestZipCode":"$(basename $@)","maxDistance":"10","lbro":"","requestType":"collectionbox","requestServices":"bluebox","requestRefineTypes":"","requestRefineHours":"","requestZipPlusFour":""}' \
  --compressed > $@