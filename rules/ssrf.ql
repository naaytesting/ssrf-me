import go
import semmle.code.go.reflect.reflect

class HttpRequest extends go.Builtin { }

class HttpResponseWriter extends go.Builtin { }

class HttpClient extends go.Builtin { }

class FuncDecl extends go.Function { }

class MethodCall extends go.Call { }

predicate isHttpRequest(go.Expr e) {
  e.dereference() instanceof HttpRequest
}

predicate isHttpResponseWriter(go.Expr e) {
  e.dereference() instanceof HttpResponseWriter
}

predicate isHttpClient(go.Expr e) {
  e.dereference() instanceof HttpClient
}

predicate isHttpMethod(MethodCall call) {
  call.getSelector() == "Get" or
  call.getSelector() == "Post" or
  call.getSelector() == "Put" or
  call.getSelector() == "Delete" or
  call.getSelector() == "Client.Do"
}

predicate isHttpRequestQuery(MethodCall call) {
  call.getSelector() == "URL.Query" and
  exists(MethodCall c | c.getTarget() == call.getArgument(0) and isHttpMethod(c))
}

FuncDecl funcDecl(HttpRequest req, HttpResponseWriter resp, HttpClient client) {
  exists(FuncDecl f |
    f.getParameters().any(isHttpRequest) and
    f.getParameters().any(isHttpResponseWriter) and
    f.getBody().any(MethodCall, isHttpMethod) and
    f.getBody().any(MethodCall, isHttpRequestQuery)
  )
}

query http_request_query_params_queried_via_http {
  // Find all functions where HTTP Request query parameters are later queried via HTTP
  funcDecl(...)
}
