<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<%
    copinfo = info.branches().get('COP Info')
    if copinfo:
        copbranches = copinfo.branches()
        planes = copbranches.get('Planes')
        metadata = copbranches.get("Metadata")

        dependencies = copbranches.get('Dependencies')
        dependencies = dependencies.rows() if dependencies else None

        renames = {
            "Total Bytes per Pixel": "Bytes/pixel",
        }
%>

%if copinfo:
    ${self.properties(copinfo, renames=renames)}

    %if metadata:
        <hr />
        ${self.properties(metadata)}
    %endif

    %if planes:
        <hr />
        ${self.branch_table(planes)}
    %endif

    ## COP2 dependency info is broken, and Mark A has no plans to fix it in the
    ## near future, so don't display it in the info window
%endif
