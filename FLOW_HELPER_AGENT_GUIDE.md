# Flow Helper Agent - Setup & Usage Guide

## Overview
The **Flow Helper Agent** is a Salesforce Agentforce agent that helps users navigate, find, and understand flows in your Salesforce org through conversational AI.

## What It Does

### 🔍 Search Flows
- Find flows by keyword in name, description, or developer name
- Filter by flow type (Trigger-Based, Scheduled, Screen Flow, etc.)
- Returns up to 20 matching flows with descriptions

### 📋 Get Flow Details
- Retrieve detailed information about a specific flow
- Shows flow name, description, type, and status
- Helps users understand what a flow does

### 📊 List Flow Types
- Shows all available flow types in your org
- Explains the purpose of each type
- Helps users narrow down their search

## Architecture

### Components

#### 1. **FlowHelper Apex Class** (`force-app/main/default/classes/FlowHelper.cls`)
- Handles all flow-related operations
- Single `@InvocableMethod` that routes to different actions based on request
- Three supported actions: `search`, `details`, `list-types`
- Currently uses mock data (can be updated with real SOQL queries)

#### 2. **Flow_Helper_Agent Bundle** (`force-app/main/default/aiAuthoringBundles/Flow_Helper_Agent/`)
- Main agent script file (`.agent`)
- Bundle metadata file (`.bundle-meta.xml`)

#### 3. **Agent Script Structure**
- **Main Router**: Routes user requests to appropriate subagents
- **flow_search**: Handles flow searching
- **flow_details**: Handles detailed flow information lookups
- **list_flows**: Handles listing available flow types

## How to Use

### Testing in Salesforce
1. Log into your Salesforce sandbox: `alexandra.prechtl@frontify.com.fancyai`
2. Navigate to **Agentforce** or **Agent Management**
3. Find "Flow Helper Agent"
4. Click to open and start testing

### Example Queries
- "Find all trigger-based flows"
- "Tell me about the Lead Qualification flow"
- "What flow types are available?"
- "Search for flows with 'account' in the name"
- "Do you have any scheduled flows?"
- "I need flows for opportunity management"

## Customization

### Updating with Real Flow Data
To replace mock data with actual flows from your org:

1. Edit `force-app/main/default/classes/FlowHelper.cls`
2. Replace the `getMockFlows()` method with real SOQL queries
3. Example SOQL to query actual flows:
   ```apex
   List<FlowDefinition> flows = [
       SELECT Id, DeveloperName, MasterLabel, Description, ProcessType, IsActive
       FROM FlowDefinition
       WHERE IsActive = true
   ];
   ```

### Adding More Capabilities
The agent can be extended to:
- Show flow execution history
- Provide flow performance metrics
- Link to flow documentation
- Recommend flows based on use case
- Show flows by process type or trigger event

## File Locations

```
force-app/main/default/
├── classes/
│   ├── FlowHelper.cls              # Main Apex class
│   └── FlowHelper.cls-meta.xml     # Apex metadata
└── aiAuthoringBundles/
    └── Flow_Helper_Agent/
        ├── Flow_Helper_Agent.agent          # Agent script
        └── Flow_Helper_Agent.bundle-meta.xml  # Bundle metadata
```

## Deployment

### Initial Deployment
```bash
sf project deploy start --source-dir force-app/main/default/classes/FlowHelper.cls
sf project deploy start --source-dir force-app/main/default/aiAuthoringBundles/Flow_Helper_Agent/
```

### Update Deployment
```bash
sf project deploy start
```

## Mock Data Flows

Currently testing with these flows:
- **Lead Qualification** (Trigger-Based) - Automatically qualifies leads based on score and industry
- **Account Creation** (Trigger-Based) - Creates account record and sets up related objects
- **Daily Report Generation** (Scheduled) - Generates daily sales reports and emails to managers
- **Contact Onboarding** (Screen Flow) - Guides new contacts through onboarding process
- **Opportunity Close Notification** (Trigger-Based) - Notifies stakeholders when opportunities are closed

## Next Steps

1. ✅ Test the agent in your Salesforce org
2. 🔄 Update mock data with real flows from your org
3. 🎨 Customize agent responses and routing logic
4. 📚 Add more advanced features (metrics, documentation links, etc.)
5. 👥 Set permissions and agent user configuration

## Troubleshooting

### Agent Not Responding
- Verify deployment succeeded: `sf project deploy start --check-deploy-status 0AfVE00000NEIPd0AP`
- Check Apex class is compiled without errors
- Ensure agent user has correct permissions

### Flow Data Not Updating
- Update `getMockFlows()` method with real data
- Redeploy Apex class: `sf project deploy start --source-dir force-app/main/default/classes/`
- Wait a few minutes for org to sync

### Routing Issues
- Check agent script syntax in `.agent` file
- Verify subagent names match exactly
- Test routing logic in smaller sections

---

**Created:** May 29, 2026  
**Agent Type:** Agentforce (Next-Gen Agent)  
**Status:** Deployed to Sandbox
