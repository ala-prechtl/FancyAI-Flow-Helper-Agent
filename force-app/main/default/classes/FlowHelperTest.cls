@isTest
private class FlowHelperTest {
  @isTest
  static void searchFlows_exactMatchWorks() {
    FlowHelper.FlowHelperRequest request = new FlowHelper.FlowHelperRequest();
    request.action = 'search';
    request.searchKeyword = 'Account';

    List<FlowHelper.FlowHelperResponse> responses = FlowHelper.getFlowInfo(
      new List<FlowHelper.FlowHelperRequest>{ request }
    );

    List<Object> flows = (List<Object>) JSON.deserializeUntyped(
      responses[0].flowList
    );
    System.assertEquals(true, responses[0].success);
    System.assertEquals(1, flows.size());
  }

  @isTest
  static void searchFlows_fuzzyMatchSupportsTypos() {
    FlowHelper.FlowHelperRequest request = new FlowHelper.FlowHelperRequest();
    request.action = 'search';
    request.searchKeyword = 'Lead Qualifiction';

    List<FlowHelper.FlowHelperResponse> responses = FlowHelper.getFlowInfo(
      new List<FlowHelper.FlowHelperRequest>{ request }
    );

    List<Object> flows = (List<Object>) JSON.deserializeUntyped(
      responses[0].flowList
    );
    Map<String, Object> firstFlow = (Map<String, Object>) flows[0];

    System.assertEquals(true, responses[0].success);
    System.assertEquals(1, flows.size());
    System.assertEquals('Lead Qualification', (String) firstFlow.get('name'));
  }

  @isTest
  static void searchFlows_nonMatchStillReturnsNoResults() {
    FlowHelper.FlowHelperRequest request = new FlowHelper.FlowHelperRequest();
    request.action = 'search';
    request.searchKeyword = 'zzzzzzzz';

    List<FlowHelper.FlowHelperResponse> responses = FlowHelper.getFlowInfo(
      new List<FlowHelper.FlowHelperRequest>{ request }
    );

    System.assertEquals(true, responses[0].success);
    System.assertEquals(
      'No flows found matching your search criteria.',
      responses[0].message
    );
    System.assertEquals('', responses[0].flowList);
  }
}
