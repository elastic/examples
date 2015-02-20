__author__ = 'pkim'

import csv
import json

def main():

    zip_dict = dict()
    with open('US.txt', 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        for row in reader:
            if row[9] and row[10]:
                this_dict = dict()
                this_dict['zipCode'] = row[1]
                this_dict['city'] = row[2]
                this_dict['state'] = row[3]
                this_dict['stateAbbrev'] = row[4]
                this_dict['coords'] = row[9] + "," + row[10]

                zip_dict[row[1]] = this_dict

    # supplement original list with other zip code list
    with open('zip_codes.csv', 'r') as f:
        reader = csv.reader(f, delimiter=',')
        for row in reader:
            if (row[0] not in zip_dict) and (row[1] and row[2]):
                this_dict = dict()
                this_dict['zipCode'] = row[0]
                this_dict['city'] = row[3]
                this_dict['state'] = row[4]
                this_dict['coords'] = row[1] + "," + row[2]

                zip_dict[row[0]] = this_dict
    

    # load candidate data to dict
    candidate_dict = dict()
    with open('cn.txt', 'r') as f:
        reader = csv.reader(f, delimiter='|')
        for row in reader:
            this_dict = dict()
            this_dict['candidateId'] = row[0]
            this_dict['candidateName'] = row[1]
            this_dict['candidateParty'] = row[2]
            this_dict['candidateElectionYear'] = row[3]
            this_dict['candidateOfficeState'] = row[4]
            this_dict['candidateOffice'] = row[5]
            this_dict['candidateOfficeDistrict'] = row[6]
            this_dict['incumbentChallengerStatus'] = row[7]

            candidate_dict[row[0]] = this_dict
    
    # load candidate to committee mapping to dict
    ccl_dict = dict()
    with open('ccl.txt', 'r') as f:
        reader = csv.reader(f, delimiter='|')
        for row in reader:
            this_dict = dict()
            this_dict['candidateId'] = row[0]
            this_dict['committeeId'] = row[3]

            ccl_dict[row[3]] = this_dict
    
    # load committee data to dict
    committee_dict = dict()
    with open('cm.txt', 'r') as f:
        reader = csv.reader(f, delimiter='|')
        for row in reader:
            this_dict = dict()
            this_dict['committeeId'] = row[0]
            this_dict['committeeName'] = row[1]
            this_dict['committeeDesignation'] = row[8]
            this_dict['committeeType'] = row[9]
            this_dict['committeeParty'] = row[10]
            this_dict['interestGroupCategory'] = row[12]
            # if committee is tied to candidate, then join in candidate details
            # if (row[0] in ccl_dict):
            #     candidateId = ccl_dict[row[0]]['candidateId']
            #     this_dict['candidate'] = candidate_dict[candidateId]

            committee_dict[row[0]] = this_dict

    # process individual contributions
    with open('itcont.txt', 'r') as f:
        with open('usfec_indiv_contrib.json', 'a') as f2:
            reader = csv.reader(f, delimiter='|')
            for row in reader:
                this_dict = dict()
                this_dict['recordNumber'] = row[20]
                # do lookup on committee
                this_dict['receivingCommittee'] = committee_dict[row[0]]
                if (row[0] in ccl_dict):
                    candidateId = ccl_dict[row[0]]['candidateId']
                    this_dict['candidate'] = candidate_dict[candidateId]
                this_dict['reportType'] = row[2]
                this_dict['primaryGeneralIndicator'] = row[3]
                this_dict['microfilmLocation'] = row[4]
                this_dict['transactionType'] = row[5]
                this_dict['entityType'] = row[6]
                this_dict['name'] = row[7]
                this_dict['city'] = row[8]
                this_dict['state'] = row[9]
                this_dict['zip'] = row[10]
                if (row[10][0:5] in zip_dict):
                    this_dict['coords'] = zip_dict[row[10][0:5]]['coords']
                this_dict['employer'] = row[11]
                this_dict['occupation'] = row[12]
                this_dict['transactionDate'] = row[13]
                this_dict['transactionAmount'] = row[14]
                this_dict['transactionID'] = row[16]
                this_dict['reportID'] = row[17]
                this_dict['recordType'] = 'indiv_contrib'
                this_dict['memo'] = row[19]

                json.dump(this_dict, f2)
                print('', file=f2)

    # process committee contributions to candidates
    with open('itpas2.txt', 'r') as f:
        with open('usfec_comm_contrib.json', 'a') as f2:
            reader = csv.reader(f, delimiter='|')
            for row in reader:
                this_dict = dict()
                this_dict['recordNumber'] = row[21]
                this_dict['contributingCommittee'] = committee_dict[row[0]]
                this_dict['reportType'] = row[2]
                this_dict['primaryGeneralIndicator'] = row[3]
                this_dict['microfilmLocation'] = row[4]
                this_dict['transactionType'] = row[5]
                this_dict['entityType'] = row[6]
                this_dict['name'] = row[7]
                this_dict['city'] = row[8]
                this_dict['state'] = row[9]
                this_dict['zip'] = row[10]
                if (row[10][0:5] in zip_dict):
                    this_dict['coords'] = zip_dict[row[10][0:5]]['coords']
                this_dict['employer'] = row[11]
                this_dict['occupation'] = row[12]
                this_dict['transactionDate'] = row[13]
                this_dict['transactionAmount'] = row[14]
                this_dict['transactionID'] = row[17]
                this_dict['reportID'] = row[18]
                # Note: Some confusion about whether CMTE_ID or OTHER_ID is the Contributing committee ID
                # if (row[15] in committee_dict):
                #     this_dict['contributorCommittee'] = committee_dict[row[15]]
                this_dict['recordType'] = 'comm2cand_contrib'
                this_dict['memo'] = row[20]
                # if committee contribution has candidate info, do lookup and join
                if (row[16] in candidate_dict):
                    this_dict['candidate'] = candidate_dict[row[16]]

                json.dump(this_dict, f2)
                print('', file=f2)
                
    # process contributions from committee to committee
    with open('itoth.txt', 'r') as f:
        with open('usfec_comm2comm_contrib.json', 'a') as f2:
            reader = csv.reader(f, delimiter='|')
            for row in reader:
                this_dict = dict()
                if (row[5].startswith("1")):
                    recipientCommitteeId = row[0]
                    contributorCommitteeId = row[15]
                else:
                    recipientCommitteeId = row[15]
                    contributorCommitteeId = row[0]
                this_dict['recordNumber'] = row[20]
                if (recipientCommitteeId in committee_dict):
                    this_dict['receivingCommittee'] = committee_dict[recipientCommitteeId]
                this_dict['reportType'] = row[2]
                this_dict['primaryGeneralIndicator'] = row[3]
                this_dict['microfilmLocation'] = row[4]
                this_dict['transactionType'] = row[5]
                this_dict['entityType'] = row[6]
                this_dict['name'] = row[7]
                this_dict['city'] = row[8]
                this_dict['state'] = row[9]
                this_dict['zip'] = row[10]
                if (row[10][0:5] in zip_dict):
                    this_dict['coords'] = zip_dict[row[10][0:5]]['coords']
                this_dict['employer'] = row[11]
                this_dict['occupation'] = row[12]
                this_dict['transactionDate'] = row[13]
                this_dict['transactionAmount'] = row[14]
                this_dict['transactionID'] = row[16]
                this_dict['reportID'] = row[17]
                this_dict['recordType'] = 'comm2comm_contrib'
                this_dict['memo'] = row[19]
                # join committee info
                if (contributorCommitteeId in committee_dict):
                    this_dict['contributingCommittee'] = committee_dict[contributorCommitteeId]

                json.dump(this_dict, f2)
                print('', file=f2)    
                
    # process operating expenditures
    with open('oppexp.txt', 'r') as f:
        with open('usfec_oppexp.json', 'a') as f2:
            reader = csv.reader(f, delimiter='|')
            for row in reader:
                this_dict = dict()

                spendingCommitteeId = row[0]
                if (spendingCommitteeId in committee_dict):
                    this_dict['spendingCommittee'] = committee_dict[spendingCommitteeId]
                this_dict['reportYear'] = row[2]
                this_dict['reportType'] = row[3]
                this_dict['microfilmLocation'] = row[4]
                this_dict['lineNumber'] = row[5]
                this_dict['formType'] = row[6]
                this_dict['scheduleType'] = row[7]

                this_dict['name'] = row[8]
                this_dict['city'] = row[9]
                this_dict['state'] = row[10]
                this_dict['zip'] = row[11]
                if (row[11][0:5] in zip_dict):
                    this_dict['coords'] = zip_dict[row[11][0:5]]['coords']
                this_dict['transactionDate'] = row[12]
                this_dict['transactionAmount'] = row[13]
                this_dict['primaryGeneralIndicator'] = row[14]
                this_dict['purpose'] = row[15]
                this_dict['disbursementCategoryCode'] = row[16]
                this_dict['disbursementCategoryCodeDesc'] = row[17]
                this_dict['memo'] = row[19]
                this_dict['entityType'] = row[20]
                this_dict['recordNumber'] = row[21]
                this_dict['reportID'] = row[22]
                this_dict['transactionID'] = row[23]
                this_dict['backRefTransactionID'] = row[24]
                
                # check to see if there's a candidate associated with the committee
                if (row[0] in ccl_dict):
                    candidateId = ccl_dict[row[0]]['candidateId']
                    this_dict['candidate'] = candidate_dict[candidateId]
                
                this_dict['recordType'] = 'oppexp'


                json.dump(this_dict, f2)
                print('', file=f2)       

if __name__ == '__main__':
    main()
