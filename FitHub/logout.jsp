<%--
  Contributions: Ayman Rabia 100%
--%>
<%@ page session="true" %>
<%
    session.invalidate();
    response.sendRedirect("index.html");
%>
