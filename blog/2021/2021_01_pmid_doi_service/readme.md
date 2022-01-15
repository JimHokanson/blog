

Domain Forwarding
- Instructions: https://docs.aws.amazon.com/amplify/latest/userguide/to-add-a-custom-domain-managed-by-google-domains.html
- https://stackoverflow.com/questions/49826230/regional-edge-optimized-api-gateway-vs-regional-edge-optimized-custom-domain-nam

https://aws.amazon.com/premiumsupport/knowledge-center/custom-domain-name-amazon-api-gateway/

-NET::ERR_CERT_COMMON_NAME_INVALID api gateway

- API mappings - ?? What is this - got forbidden JSON response
- rest vs http api

This post assumes edge-optimized 
- https://medium.com/@maciejtreder/custom-domain-in-aws-api-gateway-a2b7feaf9c74



import requests
import time

t1 = time.time()
wtf = requests.get('https://ids.references.app/')
t2 = time.time()
print(t2-t1)


Certificate error:
https://urllib3.readthedocs.io/en/latest/user-guide.html#certificate-verification

