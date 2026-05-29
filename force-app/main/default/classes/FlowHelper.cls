public with sharing class FlowHelper {
    private static final Integer SHORT_TOKEN_LENGTH = 4;
    private static final Integer MEDIUM_TOKEN_LENGTH = 8;
    private static final Integer SHORT_TOKEN_THRESHOLD = 1;
    private static final Integer MEDIUM_TOKEN_THRESHOLD = 2;
    private static final Integer LONG_TOKEN_THRESHOLD = 3;

    @InvocableMethod(
        label='Get Flow Information'
        description='Get information about flows - search, details, or list types'
    )
    public static List<FlowHelperResponse> getFlowInfo(
        List<FlowHelperRequest> requests
    ) {
        FlowHelperRequest request = requests[0];
        FlowHelperResponse response = new FlowHelperResponse();
        response.success = false;
        response.message = '';
        response.flowList = '';
        response.flowName = '';
        response.flowDescription = '';
        response.flowType = '';
        
        try {
            String action = request.action;
            
            if (action == 'search') {
                handleSearchFlows(request, response);
            } else if (action == 'details') {
                handleGetFlowDetails(request, response);
            } else if (action == 'list-types') {
                handleListFlowTypes(request, response);
            } else {
                response.message = 'Unknown action: ' + action;
            }
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error: ' + e.getMessage();
        }
        
        return new List<FlowHelperResponse>{ response };
    }
    
    private static void handleSearchFlows(FlowHelperRequest request, FlowHelperResponse response) {
        String keyword = request.searchKeyword;
        String flowType = request.flowType;
        
        List<Map<String, String>> flows = getMockFlows();
        List<Map<String, String>> results = new List<Map<String, String>>();
        
        for (Map<String, String> flow : flows) {
            Boolean matchesKeyword = String.isBlank(keyword) || 
                isFuzzyMatch(keyword, flow.get('name')) ||
                isFuzzyMatch(keyword, flow.get('developer_name')) ||
                isFuzzyMatch(keyword, flow.get('description'));
            
            Boolean matchesType = String.isBlank(flowType) || 
                flow.get('flow_type').equalsIgnoreCase(flowType);
            
            if (matchesKeyword && matchesType) {
                results.add(flow);
            }
        }
        
        if (results.isEmpty()) {
            response.message = 'No flows found matching your search criteria.';
        } else {
            response.message = 'Found ' + results.size() + ' flow(s).';
            response.flowList = JSON.serialize(results);
        }
        response.success = true;
    }

    private static Boolean isFuzzyMatch(String keyword, String valueToSearch) {
        if (String.isBlank(valueToSearch)) {
            return false;
        }

        String normalizedKeyword = normalizeForFuzzy(keyword);
        String normalizedValue = normalizeForFuzzy(valueToSearch);

        if (normalizedValue.contains(normalizedKeyword)) {
            return true;
        }

        List<String> keywordTokens = normalizedKeyword.split('\\s+');
        List<String> valueTokens = normalizedValue.split('\\s+');

        for (String keywordToken : keywordTokens) {
            if (String.isBlank(keywordToken)) {
                continue;
            }

            Boolean tokenMatched = false;
            for (String valueToken : valueTokens) {
                Integer threshold = getFuzzyThreshold(keywordToken, valueToken);
                if (
                    valueToken.contains(keywordToken) ||
                    keywordToken.contains(valueToken) ||
                    getLevenshteinDistance(keywordToken, valueToken, threshold) <= threshold
                ) {
                    tokenMatched = true;
                    break;
                }
            }

            if (!tokenMatched) {
                return false;
            }
        }

        return true;
    }

    private static String normalizeForFuzzy(String input) {
        String normalized = input == null ? '' : input.toLowerCase();
        normalized = normalized.replace('_', ' ').replace('-', ' ');
        normalized = normalized.replaceAll('[^a-z0-9 ]', ' ');
        normalized = normalized.replaceAll('\\s+', ' ').trim();
        return normalized;
    }

    private static Integer getFuzzyThreshold(String source, String target) {
        Integer minLength = Math.min(source.length(), target.length());
        if (minLength <= SHORT_TOKEN_LENGTH) {
            return SHORT_TOKEN_THRESHOLD;
        }
        if (minLength <= MEDIUM_TOKEN_LENGTH) {
            return MEDIUM_TOKEN_THRESHOLD;
        }
        return LONG_TOKEN_THRESHOLD;
    }

    private static Integer getLevenshteinDistance(String source, String target, Integer maxDistance) {
        Integer sourceLength = source.length();
        Integer targetLength = target.length();

        List<Integer> previousRow = new List<Integer>();
        for (Integer i = 0; i <= targetLength; i++) {
            previousRow.add(i);
        }

        for (Integer i = 1; i <= sourceLength; i++) {
            List<Integer> currentRow = new List<Integer>{ i };
            Integer rowMinimum = i;
            for (Integer j = 1; j <= targetLength; j++) {
                Integer substitutionCost = source.substring(i - 1, i) == target.substring(j - 1, j) ? 0 : 1;
                Integer insertion = currentRow.get(j - 1) + 1;
                Integer deletion = previousRow.get(j) + 1;
                Integer substitution = previousRow.get(j - 1) + substitutionCost;
                Integer distance = Math.min(insertion, Math.min(deletion, substitution));
                currentRow.add(distance);
                rowMinimum = Math.min(rowMinimum, distance);
            }
            if (rowMinimum > maxDistance) {
                return maxDistance + 1;
            }
            previousRow = currentRow;
        }

        return previousRow.get(targetLength);
    }
    
    private static void handleGetFlowDetails(FlowHelperRequest request, FlowHelperResponse response) {
        String flowName = request.flowName;
        
        List<Map<String, String>> flows = getMockFlows();
        
        for (Map<String, String> flow : flows) {
            if (flow.get('name').equalsIgnoreCase(flowName) || 
                flow.get('developer_name').equalsIgnoreCase(flowName)) {
                response.success = true;
                response.flowName = flow.get('name');
                response.flowDescription = flow.get('description');
                response.flowType = flow.get('flow_type');
                response.message = 'Flow details retrieved successfully.';
                return;
            }
        }
        
        response.success = false;
        response.message = 'Flow "' + flowName + '" not found.';
    }
    
    private static void handleListFlowTypes(FlowHelperRequest request, FlowHelperResponse response) {
        Set<String> types = new Set<String>();
        
        List<Map<String, String>> flows = getMockFlows();
        for (Map<String, String> flow : flows) {
            types.add(flow.get('flow_type'));
        }
        
        List<String> typeList = new List<String>(types);
        typeList.sort();
        
        response.flowList = JSON.serialize(typeList);
        response.message = 'Found ' + types.size() + ' flow type(s).';
        response.success = true;
    }
    
    private static List<Map<String, String>> getMockFlows() {
        return new List<Map<String, String>>{
            new Map<String, String>{
                'name' => 'Lead Qualification',
                'developer_name' => 'Lead_Qualification',
                'description' => 'Automatically qualifies leads based on score and industry',
                'flow_type' => 'Trigger-Based'
            },
            new Map<String, String>{
                'name' => 'Account Creation',
                'developer_name' => 'Account_Creation',
                'description' => 'Creates account record and sets up related objects',
                'flow_type' => 'Trigger-Based'
            },
            new Map<String, String>{
                'name' => 'Daily Report Generation',
                'developer_name' => 'Daily_Report_Generation',
                'description' => 'Generates daily sales reports and emails to managers',
                'flow_type' => 'Scheduled'
            },
            new Map<String, String>{
                'name' => 'Contact Onboarding',
                'developer_name' => 'Contact_Onboarding',
                'description' => 'Guides new contacts through onboarding process with screens',
                'flow_type' => 'Screen Flow'
            },
            new Map<String, String>{
                'name' => 'Opportunity Close Notification',
                'developer_name' => 'Opportunity_Close_Notification',
                'description' => 'Notifies stakeholders when opportunities are closed',
                'flow_type' => 'Trigger-Based'
            }
        };
    }

    public class FlowHelperRequest {
        @InvocableVariable(
            required=true
            description='Action to perform: search, details, or list-types'
        )
        public String action;
        
        @InvocableVariable(
            required=false
            description='Keyword to search in flow name, description, or developer name'
        )
        public String searchKeyword;
        
        @InvocableVariable(
            required=false
            description='Flow type to filter by (e.g., "Trigger-Based", "Scheduled")'
        )
        public String flowType;
        
        @InvocableVariable(
            required=false
            description='The name or developer name of the flow to get details for'
        )
        public String flowName;
    }

    public class FlowHelperResponse {
        @InvocableVariable(
            description='Whether the request was successful'
        )
        public Boolean success;
        
        @InvocableVariable(
            description='Status or result message'
        )
        public String message;
        
        @InvocableVariable(
            description='JSON-serialized list of flows (for search results)'
        )
        public String flowList;
        
        @InvocableVariable(
            description='The flow display name'
        )
        public String flowName;
        
        @InvocableVariable(
            description='Description of what the flow does'
        )
        public String flowDescription;
        
        @InvocableVariable(
            description='Type of flow (e.g., Trigger-Based, Scheduled)'
        )
        public String flowType;
    }
}
