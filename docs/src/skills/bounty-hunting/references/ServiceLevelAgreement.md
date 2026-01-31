# Services Agreement Template for a Smart Contract Audit

This Services Agreement ("Agreement") is entered into between [Client Name], hereinafter referred to as "Client," and [Auditor Name], hereinafter referred to as "Auditor," collectively referred to as the "Parties."

## 1. Scope of Work

The Auditor agrees to perform a security audit of the Client's smart contracts deployed on [blockchain network], specifically [list contract addresses or repository links]. The audit will assess the code for vulnerabilities, logic errors, and compliance with industry best practices.

## 2. Audit Process

- Initial Review: The Auditor will perform an initial assessment of the smart contract code and share preliminary findings.
- Client Feedback: The Client may address the findings and implement fixes based on the initial review.
- Final Review: The Auditor will review the updated code and prepare a final audit report.
- Report Delivery: The final report will detail vulnerabilities, recommendations, and an overall security assessment.

## 3. Timeline

The audit will begin on [start date] and is expected to conclude by [end date], with the final report delivered by [report delivery date]. The Auditor is available to work from the 1st to the 21st of each month, dedicating 12 hours per day, 7 days a week, for a total of 21 consecutive days.

## 4. Pricing and Payment Terms

### 4.1 Pricing Formula

The total fee for the audit is calculated based on the number of Solidity lines of code (SLOC), determined using the following method:

- Code Formatting:
  The Solidity code must be formatted using forge fmt with the following settings:
  ```bash
   export FOUNDRY_FMT_SINGLE_LINE_STATEMENT_BLOCKS="multi"
   export FOUNDRY_FMT_LINE_LENGTH=90
   export FOUNDRY_FMT_TAB_WIDTH=4
   export FOUNDRY_FMT_MULTILINE_FUNC_HEADER="params_first_multi"
   export FOUNDRY_FMT_BRACKET_SPACING=false
   export FOUNDRY_FMT_INT_TYPES="long"
   export FOUNDRY_FMT_QUOTE_STYLE="double"
   export FOUNDRY_FMT_NUMBER_UNDERSCORE="thousands"
   export FOUNDRY_FMT_HEX_UNDERSCORE="remove"
   export FOUNDRY_FMT_OVERRIDE_SPACING=false
   export FOUNDRY_FMT_WRAP_COMMENTS=false
   export FOUNDRY_FMT_CONTRACT_NEW_LINES=true
   export FOUNDRY_FMT_SORT_IMPORTS=true
  ```
- Counting Lines of Code:
  After formatting, the SLOC will be calculated using cloc, a GNU utility, based on its output for Solidity files.
- The total fee is determined by the formula:

$Total Fee = \left( \frac{a \times \text{testing factor}}{200} + 12 \right) \times 200 \text{ USD}$

Where:

- ( a ) = SLOC, as calculated by cloc after formatting with forge fmt using the settings above.
- Testing factor = 2 (if the Client provides tests) or 3 (if the Auditor must write tests for Proof of Concept (POC)).

- Audit Time: The adjusted SLOC (after applying the testing factor) is divided by 200 (assuming the Auditor audits 200 SLOC per hour).

- Report Compilation: An additional 12 hours is added for compiling the audit report and quality-of-life (QOL) documentation.

- Hourly Rate: The total hours are multiplied by the Auditor’s rate of {200 USD} per hour.

### 4.2 Deposit

The Client shall pay a 30% non-refundable deposit of the estimated total fee upon signing this Agreement. The estimate will be based on an initial SLOC count provided by the Client.

### 4.3 Final Payment

The final payment will be adjusted based on the actual SLOC count at the time of the audit and is due upon delivery of the final audit report.

### 4.4 Payment Method

Payments shall be made in [cryptocurrency, e.g., ETH, USDC] to the Auditor’s wallet address [wallet address].

### 4.5 Late Payments

Late payments will incur interest at [rate] per [time period].

## 5. Responsibilities

Client Responsibilities:

- Provide the final commit of the smart contracts by [date].
- Indicate whether tests are provided or if the Auditor must write tests for POC.
- Be available for meetings and discussions as required.
- Implement recommended fixes from the audit findings.

Auditor Responsibilities:

- Perform the audit with professionalism and diligence.
- Deliver a comprehensive final report by the agreed delivery date.
- Maintain confidentiality of the Client’s information.

## 6. Changes and Unforeseen Circumstances

- Scope Changes: Any changes to the scope must be agreed in writing and may adjust the timeline and fees. New functionality added during the fix audit may incur additional costs.

- Auditor Unavailability: If the Auditor cannot perform the audit due to unforeseen circumstances, a qualified replacement will be provided, or the timeline will be adjusted.

- Client Delays: If the Client is not ready by the start date, the Auditor may reschedule or charge additional fees.

- SLOC Disputes: Any disagreements over the SLOC count will be resolved by re-running cloc on the code formatted with the specified forge fmt settings.

## 7. Intellectual Property

The Auditor retains ownership of any tools, methodologies, or concepts developed during the audit, unless otherwise agreed.

## 8. Liability Limitations

The Auditor is not liable for undetected vulnerabilities or exploits after the audit. The Client understands that the audit is a point-in-time evaluation and does not ensure absolute security.

## 9. Cancellation Policy

The Client may cancel with at least 7 days’ notice, forfeiting the deposit. Cancellations with less than 7 days’ notice will incur a fee of 50% of the estimated total fee.
The Auditor may cancel if the Client fails to meet their obligations, with the deposit remaining non-refundable.

## 10. Dispute Resolution

Disputes arising from this Agreement will be resolved through [mediation, arbitration, or jurisdiction-specific legal process].

## 11. Compliance and Legal Framework

The Client confirms that all funds used for payment are from legitimate sources and comply with anti-money laundering (AML) regulations.
The Auditor may require the Client to complete know-your-business (KYB) procedures before starting the audit.
Both Parties agree to adhere to applicable laws and regulations.

## 12. Miscellaneous

Confidentiality: Both Parties will protect sensitive information shared during the engagement.
Report Publication: The Auditor may publish the audit report after 30 days from delivery, unless the Client objects in writing.
Governing Law: This Agreement is governed by the laws of [jurisdiction].

## 13. Signatures

By signing below, both Parties confirm they have read, understood, and agree to be bound by this Agreement.

[Client Signature]
[Date]
[Auditor Signature]
[Date]
