
 
REM export a password for use with the system (no quotes)

more config.json | jq-win64.exe ".serviceUrl" >> temp.txt
set /p serviceUrl=<temp.txt
del -f temp.txt

more config.json | jq-win64.exe ".username" >> temp.txt
set /p username=<temp.txt
del -f temp.txt

more config.json | jq-win64.exe ".password" >> temp.txt
set /p password=<temp.txt
del -f temp.txt

more config.json | jq-win64.exe ".recordingStopperTime" >> temp.txt
set /p recordingStopperTime=<temp.txt
del -f temp.txt

more config.json | jq-win64.exe ".useCaseId" >> temp.txt
set /p useCaseId=<temp.txt
del -f temp.txt

more config.json | jq-win64.exe ".configIdentifier" >> temp.txt
set /p configIdentifier=<temp.txt
del -f temp.txt

:start

curl -X POST %serviceUrl%oauth/token -u "performanceDashboardClientId:ljknsqy9tp6123" -d "grant_type=password" -d "username=%username%" -d "password=%password%" >> temp.txt
more temp.txt | jq-win64.exe ".access_token" >> accessToken.txt
set /p accessToken=<accessToken.txt
del -f temp.txt
del -f accessToken.txt
if %accessToken%==null (goto :showMessage)

curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/startRecording?usecaseIdentifier="customer" -i
for /l %%x in (1, 1, 2) do (
mysql -h localhost -P 3306 -uroot -proot -D Database_Name < customer.txt > out_customer_result.txt
)
curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/stopRecording?usecaseIdentifier="customer&inputSource=batFile" -i

curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/startRecording?usecaseIdentifier="product_list" -i
for /l %%x in (1, 1, 4) do (
mysql -h localhost -P 3306 -uroot -proot -D Database_Name < product_list.txt > out_product_result.txt
curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/stopRecording?usecaseIdentifier="product_list&inputSource=batFile" -i

)

curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/startRecording?usecaseIdentifier="products_options" -i
mysql -h localhost -P 3306 -uroot -proot-D Database_Name < products_options.txt > out_products_options_result.txt

curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/stopRecording?usecaseIdentifier="products_options&inputSource=batFile" -i

curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/startRecording?usecaseIdentifier="tax_rates" -i
for /l %%x in (1, 1, 9) do (
mysql -h localhost -P 3306 -uroot -proot -D Database_Name < tax_rates.txt > out_tax_rate_results.txt
curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/stopRecording?usecaseIdentifier="tax_rates&inputSource=batFile" -i
)
curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/startRecording?usecaseIdentifier="zones" -i
mysql -h localhost -P 3306 -uroot -proot -D Database_Name < zones.txt > out_zones_result.txt 
curl -v -H "Authorization: Bearer %accessToken%", -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/stopRecording?usecaseIdentifier="zones&inputSource=batFile" -i


curl -v -H "Authorization: Bearer %accessToken%" -H "configIdentifier:%configIdentifier%" -X GET %serviceUrl%devaten/data/generateReport >> response.json
