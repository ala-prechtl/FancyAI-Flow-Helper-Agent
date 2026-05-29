@isTest
private class FlowHelperTest {
  @isTest
  static void searchFlows_withTypoInDisplayName_returnsExpectedMatch() {
    FlowHelper.FlowHelperRequest req = new FlowHelper.FlowHelperRequest();
    req.action = 'search';
    req.searchKeyword = 'Acount';

    List<FlowHelper.FlowHelperResponse> responses = FlowHelper.getFlowInfo(
      new List<FlowHelper.FlowHelperRequest>{ req }
    );

    System.assertEquals(true, responses[0].success);
    List<Object> parsedResults = (List<Object>) JSON.deserializeUntyped(
      responses[0].flowList
    );
    System.assertEquals(1, parsedResults.size());
    Map<String, Object> firstResult = (Map<String, Object>) parsedResults[0];
    System.assertEquals('Account Creation', (String) firstResult.get('name'));
  }

  @isTest
  static void searchFlows_withTypoInDeveloperName_returnsExpectedMatch() {
    FlowHelper.FlowHelperRequest req = new FlowHelper.FlowHelperRequest();
    req.action = 'search';
    req.searchKeyword = 'Lead_Qualifiction';

    List<FlowHelper.FlowHelperResponse> responses = FlowHelper.getFlowInfo(
      new List<FlowHelper.FlowHelperRequest>{ req }
    );

    System.assertEquals(true, responses[0].success);
    List<Object> parsedResults = (List<Object>) JSON.deserializeUntyped(
      responses[0].flowList
    );
    System.assertEquals(1, parsedResults.size());
    Map<String, Object> firstResult = (Map<String, Object>) parsedResults[0];
    System.assertEquals('Lead Qualification', (String) firstResult.get('name'));
  }

  @isTest
  static void searchFlows_withUnrelatedKeyword_returnsNoResults() {
    FlowHelper.FlowHelperRequest req = new FlowHelper.FlowHelperRequest();
    req.action = 'search';
    req.searchKeyword = 'xyznonexisting';

    List<FlowHelper.FlowHelperResponse> responses = FlowHelper.getFlowInfo(
      new List<FlowHelper.FlowHelperRequest>{ req }
    );

    System.assertEquals(true, responses[0].success);
    System.assertEquals(
      'No flows found matching your search criteria.',
      responses[0].message
    );
    System.assertEquals('', responses[0].flowList);
  }
}
