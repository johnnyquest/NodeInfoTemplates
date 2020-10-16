<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<%def name="parameters(branch)">
    % if branch is not None:
	<p>Parameters:</p>
	<table>
	    % for row in branch.rows():
		<%
		    cols = branch.headings()
		    parm = row[cols.index('Parameter')]
		    type = row[cols.index('Type')]
		    size = int(row[cols.index('Size')])
		%>
		<tr>
		<td>
		    ${type}
		</td>
		<td>
		    % if size > 1:
			${parm}[${size}]
		    % else:
			${parm}
		    % endif
		</td>
		</tr>
	    % endfor
	</table>
    % endif
</%def>

<%
    parminfo = info.branches().get('Scripted SHOP Info', None)
    shaderinfo = info.branches().get('Shader SHOP Info', None)
%>

% if parminfo:
    ${self.parameters(parminfo)}
% endif
% if shaderinfo:
    ${self.properties(shaderinfo)}
% endif
% if parminfo is None and shaderinfo is None:
    No specific information available for this SHOP.
% endif

