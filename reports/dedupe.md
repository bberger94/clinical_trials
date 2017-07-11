\clearpage

# dedupe

dedupe is a python library that uses machine learning to perform fuzzy matching, deduplication and entity resolution quickly on structured data.

dedupe will help you:

* remove duplicate entries from a spreadsheet of names and addresses
* link a list with customer information to another with order history, even without unique customer IDs
* take a database of campaign contributions and figure out which ones were made by the same person, even if the names were entered slightly differently for each record

dedupe takes in human training data and comes up with the best rules
for your dataset to quickly and automatically find similar records,
even with very large databases.

## Links

code: [https://github.com/datamade/dedupe](https://github.com/datamade/dedupe)

documentation: [https://dedupe.readthedocs.io/en/latest/](https://dedupe.readthedocs.io/en/latest/)

how it works: [https://dedupe.readthedocs.io/en/latest/How-it-works.html](https://dedupe.readthedocs.io/en/latest/How-it-works.html)

API: [https://dedupe.readthedocs.io/en/latest/API-documentation.html](https://dedupe.readthedocs.io/en/latest/API-documentation.html)

variable types: [https://dedupe.readthedocs.io/en/latest/Variable-definition.html](https://dedupe.readthedocs.io/en/latest/Variable-definition.html)

\clearpage

# Cortellis

## Merger and Acquisition Data

There are 51,047 deals in the Cortellis Investigational Drugs API.

I downloaded 27,658 this morning before hitting an error I need to investigate.

## Types of Deals

    +----------+----------------------------------------------+
    |    Count | Type                                         |
    +----------+----------------------------------------------+
    |      154 | Company - Joint Venture                      |
    |      180 | Company - M&A (in whole or part)             |
    |      460 | Drug - Asset Divestment                      |
    |      192 | Drug - Authorized Generic                    |
    |     2026 | Drug - Commercialization License             |
    |      131 | Drug - CRADA                                 |
    |     1992 | Drug - Development Services                  |
    |     5030 | Drug - Development/Commercialization License |
    |      566 | Drug - Discovery/Design                      |
    |     3538 | Drug - Early Research/Development            |
    |     5627 | Drug - Funding                               |
    |     1658 | Drug - Manufacturing/Supply                  |
    |      496 | Drug - Screening/Evaluation                  |
    |       49 | Patent - Asset Divestment                    |
    |      579 | Patent - Exclusive Rights                    |
    |       91 | Patent - Litigation Settlement               |
    |      208 | Patent - Non-Exclusive Rights                |
    |       94 | Technology - Asset Divestment                |
    |      580 | Technology - Delivery/Formulation            |
    |     3209 | Technology - Other Proprietary               |
    |      140 | Technology - Target Validation               |
    +----------+----------------------------------------------+
    
## Example Record

_Category:_

NULL

_Title:_

AmorChem to spin-off its SEMA 3A technology into semathera

_Type:_

Company - M&A (in whole or part)

_id:_

3

_FinanceDetail:_

NULL

_CompanyPrincipal:_

```javascript
{
    "@id": 1079689,
    "$": "AmorChem LP"
}
```

_DateEventMostRecent:_

"2017-01-10T18:00:00-06:00"

_MergersnAcquisitionsSummary:_

NULL

_PaymentsProjected:_

```javascript
{
    "PaymentsToPrincipal": {
        "Payment": [
            {
                "Reference": {
                    "$": 1891962
                },
                "Type": {
                    "$": "Undisclosed"
                },
                "Value": {
                    "@accuracy": "Payment Unspecified"
                }
            },
            {
                "Reference": {
                    "$": 1891962
                },
                "Type": {
                    "$": "Undisclosed"
                },
                "Value": {
                    "@accuracy": "Payment Unspecified"
                }
            }
        ]
    }
}
```

_ActionsPrimary:_

NULL

_Drugs:_

```javascript
{
    "Drug": {
        "@id": 104964,
        "DrugNameDisplay": {
            "$": "Semaphorin 3A protein inhibitor (diabetic macular edema), SemaThera"
        },
        "PhaseHighestStart": {
            "@id": "DR",
            "$": "Discovery"
        }
    }
}
```

_CrossReferences:_

```javascript
{
    "SourceEntity": [
        {
            "@type": "Company",
            "@id": 1079689,
            "TargetEntity": {
                "@type": "organizationId",
                "@id": 5037959910,
                "$": "AMORCHEM, LIMITED PARTNERSHIP"
            }
        },
        {
            "@type": "Company",
            "@id": 1142074,
            "TargetEntity": {
                "@type": "organizationId",
                "@id": 5052962443,
                "$": "Semathera Inc"
            }
        },
        {
            "@type": "ciIndication",
            "@id": 2659,
            "TargetEntity": {
                "@type": "siCondition",
                "@id": 1781
            }
        }
    ]
}
```

_Technologies:_

```javascript
{
    "Technology": {
        "@id": 762,
        "$": "Small molecule therapeutic"
    }
}
```

_TerritoriesExcluded:_

NULL

_Status:_

Active

_TimeLine:_

```javascript
{
    "Event": {
        "Date": {
            "$": "2017-01-10T18:00:00-06:00"
        },
        "Drugs": {
            "DrugLink": {
                "@nameDisplay": "Semaphorin 3A protein inhibitor (diabetic macular edema), SemaThera",
                "@id": 104964
            }
        },
        "Stage": {
            "@id": "DR",
            "$": "Discovery"
        },
        "Summary": {
            "$": "<para>- In January 2017, <ulink linkType=\"Company\" linkID=\"1079689\">AmorChem</ulink> entered into an agreement to spin-off its SEMA 3A technology into <ulink linkType=\"Company\" linkID=\"1142074\">semathera</ulink>.</para><para>- SemaThera is  focusing on development of <ulink linkType=\"Drug\" linkID=\"104964\">Sema 3A protein inhibitor</ulink> in the treatment of ocular diseases, like  diabetic macular edema.</para><para>- The first seed investment of CAD 1 million (approximately $0.75580 million) capital would allow SemaThera to select its lead candidate and start its early stage development for the treatment of DME as a first indication.</para><para>- Financial terms were undisclosed  [<ulink linkType=\"Reference\" linkID=\"1891962\">1891962</ulink>].</para>"
        },
        "Type": {
            "$": "Original Deal8"
        }
    }
}
```

_ValuesToPartner:_

```javascript
{
    "ValuePaid": {
        "@max": 0,
        "@min": 0,
        "@accuracy": "Unknown"
    },
    "ValueProjected": {
        "@max": 0,
        "@min": 0,
        "@accuracy": "Unknown"
    }
}
```

_Summary:_

```html
<para>
  In January 2017,
  <ulink linkType="Company" linkID="1079689">AmorChem</ulink>
  entered into an agreement to spin-off its SEMA 3A technology into
  <ulink linkType="Company" linkID="1142074">semathera</ulink>
  [<ulink linkType="Reference" linkID="1891962">1891962</ulink>].
</para>
```

_DateEnd:_

NULL

_ActionsSecondary:_

NULL

_FinanceSummary:_

NULL

_Patents:_

NULL

_MergersnAcquisitionsFinancial:_

NULL

_Indications:_

```javascript
{
    "Indication": {
        "@id": 2659,
        "$": "Diabetic macular edema"
    }
}
```

_IsOptional:_

N

_CompanyPartner:_

```javascript
{
    "@id": 1142074,
    "$": "SemaThera Inc"
}
```

_ValuesToPrincipal:_

```javascript
{
    "ValuePaid": {
        "@max": 0,
        "@min": 0,
        "@accuracy": "Unknown"
    },
    "ValueProjected": {
        "@max": 0,
        "@min": 0,
        "@accuracy": "Payment Unspecified"
    }
}
```

_TerritoriesIncluded:_

NULL

_DateStart:_

"2017-01-10T18:00:00-06:00"

\clearpage

# WRDS

I asked James Zeitler, in Baker Research Services, for his thoughts on determining whether a firm is public or private:

> CapitalIQ would tell you whether a company is public or private today, and might get you an IPO date, if the company went public fairly recently.  But past history isn't all that important in many databases.  And, as you probably suspect, data are notoriously sparse for [private] companies.

> Barbara's suggested looking at CRSP and/or Compustat to see when companies enter the databases.  The presumption is that they're private before turning up in one of those databases.

## Capital IQ

What are the various Capital IQ datasets?

1. Key Developments provide structured summaries of material news and events that may affect the market value of securities.
2. People Intelligence covers over 4.5 million professionals and over 2.4 million people including private and public company executives, board members, and investment professionals, globally.
3. Capital Structure provides extensive debt capital structure for over 60,000 global public and private companies and equity capital structure data on over 80,000 active and inactive companies worldwide.

Data coverage ends in 2011.

## Compustat Monthly Updates - Fundamentals Quarterly

_Library_: compm

_File_: fundq

_Data Range_: 01/01/1961 - 12/06/2016

_Update Schedule_: Monthly

\clearpage

# TODO

Finish downloading deals from Cortellis.

Determine what data to download from WRDS.

Note: In 2005, ICMJE required clinical trial registration -> focus on 11 calendar years 2006 - 2016.

Fuzzy merge Cortellis companies to financial data from WRDS.
