<%namespace name="ni" module="nodegraphinfo"/>
<%namespace name="it" module="itertools"/>
<%inherit file="base.mako"/>

<style>
<%include file="base.css"/>
<%include file="top.css"/>
p { margin: 0; padding: 0;}
</style>

<%
	state_label = "Cooking"
	if state == pdg.workItemState.CookedSuccess:
		state_label = "Cooked"
	elif state == pdg.workItemState.CookedCache:
		state_label = "Cooked from Cache"
	elif task.state == pdg.workItemState.CookedFail:
		state_label = "Failed"
	elif task.state == pdg.workItemState.CookedCancel:
		state_label = "Canceled"
	elif task.state == pdg.workItemState.Uncooked:
		state_label = "Dirty"
	elif task.state == pdg.workItemState.Dirty:
		state_label = "Dirty"
%>

<p>
    <a href="node:${node.path()}">${node.name()}</a>
</p>

<p id="workitemname" style="font-weight: bold; color: white; font-size: x-large;">
${name}
</p>

<p>
% if data:
    ${data.type.typeLabel} (${data.type.typeName})
% else:
    Task
% endif
</p>
