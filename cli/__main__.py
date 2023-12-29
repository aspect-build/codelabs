import requests
import runfiles

with open(runfiles.Create().Rlocation("_main/cli/header.txt"), "r") as f:
  print(f.read())
r = requests.get('http://localhost:8081')
print(r.json())
