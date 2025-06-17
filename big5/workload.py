import logging

logger = logging.getLogger("workload")

class PPLQueryRunner:
    """
    Runner for PPL queries in OpenSearch Benchmark.
    """
    async def __call__(self, opensearch, params):
        """
        Runs a PPL query against OpenSearch.
        
        :param opensearch: The OpenSearch client.
        :param params: A dict containing the parameters for this PPL query.
        :return: A dict containing the search results.
        """
        if "body" not in params:
            raise Exception("PPL query operation requires a 'body' parameter with the PPL query")
        
        if "query" not in params["body"]:
            raise Exception("PPL query operation requires a 'query' field in the 'body' parameter")
        
        ppl_query = params["body"]["query"]
        logger.info("Running PPL query: %s", ppl_query)
        
        try:
            # Use the PPL plugin endpoint
            response = opensearch.transport.perform_request(
                "POST",
                "/_plugins/_ppl",
                body={"query": ppl_query}
            )
            return response
        except Exception as e:
            logger.error("Error executing PPL query: %s", str(e))
            raise

def register(registry):
    """
    Registers the custom runners with OpenSearch Benchmark.
    """
    registry.register_runner("ppl-query", PPLQueryRunner(), async_runner=True)

def on_benchmark_start(client):
    """
    Called when the benchmark starts.
    """
    # Check if the PPL plugin is available
    try:
        response = client.transport.perform_request("GET", "/_cat/plugins")
        plugins = [line.split()[1] for line in response.split("\n") if line]
        if "opensearch-sql" not in plugins:
            logger.warning("OpenSearch SQL plugin not found. PPL queries may not work.")
    except Exception as e:
        logger.warning("Could not check for OpenSearch SQL plugin: %s", str(e))