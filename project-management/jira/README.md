# Jira

## Running jira

1. `sudo docker run -d -p 8081:8080 -v /media/atlassian/jira/:/var/atlassian/application-data/jira --name jira rujun/jira-core`

2. Use `atlassian-agent.jar` to generate license key.
