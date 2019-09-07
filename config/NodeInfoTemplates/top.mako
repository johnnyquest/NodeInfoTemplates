<%namespace name="ni" module="nodegraphinfo"/>
<%namespace name="it" module="itertools"/>
<%inherit file="base.mako"/>

<style>
<%include file="top.css"/>
</style>

% if isinstance(infoitem, hou.TopNode):
    <%
        import pdg

        context_name = infoitem.getPDGGraphContextName()
        pdg_name = infoitem.getPDGNodeName()
        pdg_context =  pdg.GraphContext.byName(context_name)
        pdg_node = pdg_context.graph.node(pdg_name)
    %>

    % if infoitem.isFilterOn():
        <p>
            <strong>Filtered by</strong>
            % for i, fnode in enumerate(infoitem.getFilterNodes()):
            ${', ' if i else ''}<a href="node:${ fnode.path() }">
                ${ fnode.name() }</a>
            % endfor
        </p>
    % endif

    % if pdg_node:
        <table>
            <tr>
                <td class="pdginfo" width="80px">PDG Node Name:</td>
                <td>${pdg_name}</td>
            </tr>
            <tr>
                <td class="pdginfo" width="80px">Work Items:</td>
                <td>${len(pdg_node.workItems)}</td>
            </tr>

            <%
                num_failed = 0
                num_canceled = 0
                num_cooked = 0
                num_dirty = 0
                num_cooking = 0
		results = pdg.utils.format_results(pdg_node.resultData(True),
		    pdg_node.scheduler, True, True)
		extra_results = -1
		if len(results) > 10:
		    extra_results = len(results)-10
		    results = results[:10]

                for work_item in pdg_node.workItems:
                    if work_item.isSuccessful:
                        num_cooked = num_cooked + 1
                    elif (work_item.state == pdg.workItemState.Uncooked) or \
			 (work_item.state == pdg.workItemState.Dirty):
                        num_dirty = num_dirty + 1
                    elif work_item.state == pdg.workItemState.CookedFail:
                        num_failed = num_failed + 1
		    elif work_item.state == pdg.workItemState.CookedCancel:
			num_canceled = num_canceled + 1
                    else:
                    	num_cooking = num_cooking + 1
            %>

            % if num_cooked > 0:
                <tr>
                    <td class="pdginfo" width="80px">Cooked:</td>
                    <td class="workitemcooked">${num_cooked}</td>
                </tr>
            % endif
            % if num_failed > 0:
                <tr>
                    <td class="pdginfo" width="80px">Failed:</td>
                    <td class="workitemfailed">${num_failed}</td>
                </tr>
            % endif
            % if num_canceled > 0:
                <tr>
                    <td class="pdginfo" width="80px">Canceled:</td>
                    <td class="workitemcanceled">${num_canceled}</td>
                </tr>
            % endif
            % if num_dirty > 0:
                <tr>
                    <td class="pdginfo" width="80px">Dirty:</td>
                    <td class="workitemdirty">${num_dirty}</td>
                </tr>
            %endif
            %if num_cooking > 0:
                <tr>
                    <td class="pdginfo" width="80px">Cooking:</td>
                    <td class="workitem">${num_cooking}</td>
                </tr>
            %endif

	    % if results:
	    <tr>
		    <td class="pdginfo">Output:</td>
		    <td class="value">
		    %for value, display, tag,in results:
		    <p>
			## A TOPs "results" string can be anything, we can't assume it's
			## a URL, unfortunately, so try to handle possibly clickable things
			## on a case-by-case basis :/
			<% prefix = ni.until_colon(value) %>
			% if prefix in ("file", "http", "https", "ftp"):
			    ## Clickable URLs
			    <a href="${value}">${display}</a>
			% elif value.startswith("/") or value.startswith("\\") or (len(prefix) == 1 and prefix.isalpha()):
			    ## Unix or Windows file path
			    <a href="file:${value.replace("\\", "/")}">${display}</a>
			% else:
			    ## Otherwise not clickable
			    <tt>${display}</tt>
			% endif
			<span class="resultdatatag">${tag}</span>
		    </p>
		    %endfor
		    % if extra_results > 0:
		    <p><span class="resultdatatag">... ${extra_results} more results</span></p>
		    % endif
		    </td>
	    </tr>
	    % endif


        </table>
    % endif
% endif


