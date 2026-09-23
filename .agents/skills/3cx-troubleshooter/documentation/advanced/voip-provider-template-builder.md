# 3CX V20 U9 Provider Template Builder

> Source: https://www.3cx.com/docs/voip-provider-template-builder/

Update 9 of 3CX V20 brings more great tools to manage custom provider templates. In the following examples, we will use the Generic VoIP Provider template as the starting template, and demonstrate how to implement customizations.

## Copy a default template to create a custom template

- Navigate to "Admin → Advanced → Templates → Provider Templates"
- From the dropdown, select "GenericVoIPProvider.pv.xml" and create a copy
- The Create Copy dialog allows you to select which trunk settings will be exposed when configuring a trunk with your custom template
- The Regional Country Visibility allows you to select the countries under which this custom template will be listed; keep the list empty if you want it to be listed only under "Worldwide"
- If you are making a copy of a template that is already in use with any configured trunks, the Template Migration option will, by default, synchronize the configured trunks with your new custom template when you click the Create button
- Click the Create button to save the custom template; it will now be available in the Voice and Chat menu when creating a new trunk
- The interface allows you to edit the template directly; typically you would only need to adjust the `<name>` element to better identify it in the list of templates
- The new custom template is now visible with the new name in the list of templates when creating a new trunk

## Adjusting custom template settings

You can make adjustments to the custom template via the Tune options:

- use Tune → Trunk Visibility Settings to adjust which trunk settings will be exposed
- use Tune → Provider Compatibility Options when a provider requires adjustments to:
  - Outbound Caller ID Handling
  - Inbound Caller Name Handling
  - Inbound Call Identification

## Export and import a provider template

Any built-in and any custom provider template can now be exported from the "Advanced → Templates" page; you can make edits to the template in an external editor before importing your customized version. Click the Add button to import a custom template.

## Deleting a custom provider template

You can delete a custom provider template, as long as it is NOT in use with any trunk. If your custom template is currently in use, the Delete button will be disabled. Before you can delete the custom provider template you must delete any trunks using it, or use the "Switch Template" option on any trunks using the custom provider template.

## Keeping your trunks and templates synchronized

When editing a custom provider template that is currently in use, clicking Save will present the "Apply Template Changes" dialog; click Apply to apply changes to all trunks currently using the custom template. If you click Cancel, you save the template WITHOUT applying changes to trunks.

### Sync a single trunk to its custom provider template

Navigate to Admin → Voice & Chat and select the Sync Template option for your trunk. The View Template option provides a shortcut to navigate directly to the custom provider template.

### Sync a saved custom provider template to all trunks using it

Navigate to Admin → Advanced → Templates → Provider Templates, select your custom template, and click the Apply to Trunks button.

## Tuning trunk visibility settings

The Trunk Visibility tuning options allow you to simplify the number of options needed:

- **Secondary Registrar** - controls visibility of the "Alternative Proxy" option
- **IP in Contact (Registration)** - required if your provider needs specific IP for SIP "Contact" and SDP "Connection" headers
- **Public IP Via** - required if provider requires specific IP in the "Via" header
- **Advanced Options** - exposes Transport Protocol, IP Mode, SRTP Mode, Re-Register timeout, PBX Delivers Audio, Disable Video, Support Reinvite, Support Replaces
- **TLS / Certificates** - if provider supports TLS and requires CA certificate
- **3-Way Authentication** - if provider requires 3-way authentication password
- **Authentication Type** - controls visibility of "Type of authentication" option for IP-based trunks
- **Geo911** - if provider has Geolocation support for emergency calls
- **E164** - to expose e164 number format warning

## Tuning provider compatibility options

The Provider Compatibility tuning options allow overriding specific SIP behaviours. For each section you can select ONE option.

### Outbound Caller ID Handling

- **P-Asserted-Identity (PAI)**: Use PAI with user Caller ID, main trunk number, or external Caller ID
- **Remote-Party-ID (RPID)**: Use RPID with user Caller ID or external Caller ID
- **P-Preferred-Identity (PPI)**: Use PPI with user Caller ID or external Caller ID
- **CLIP No Screening**: Send caller ID in From header

### Inbound Caller Name Handling

- Use caller number from SIP user part (recommended)
- Use caller name from SIP display name

### Inbound Call Identification

- Automatic (recommended) - uses registration (rinstance) data
- Identify inbound calls by provider host - matches Contact header host part
