#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct district {
    int id;
    char *name;
} District;

typedef struct package {
    int packageId;
    int address[18];
    int districtId;
    int street;
    int number;
    int priority;
    float weight;
    char *message;
    int messageCode;
} Package;

typedef struct postman {
    int postmanId;
    int packageCount;
    Package packages[50];
} Postman;

void read(District *districts, Package *packages, int *nrDistricts, int *nrPackages) {
    // Using pointers for nrDistricts and nrPackages to retain their values after reading
    int i, j;
    char s[100];  // A string used for reading input in a line
    
    // Start reading districts
    scanf("%d", nrDistricts);   
    getchar();   // Remove '\n' before reading the district name
    for (i = 0; i < *nrDistricts; i++) {
        districts[i].id = i;   // Automatically assign district ID
        fgets(s, 100, stdin);
        s[strchr(s, '\n') - s] = '\0';   // Replace '\n' with string terminator
        districts[i].name = (char *)malloc(strlen(s) + 1);
        strcpy(districts[i].name, s);   // Copy name into the appropriate field
    }
    
    // Continue reading packages
    scanf("%d", nrPackages);
    for (i = 0; i < *nrPackages; i++) {
        packages[i].packageId = i;   // Automatically assign package ID
        for (j = 0; j < 18; j++)
            scanf("%d", &packages[i].address[j]);
        scanf("%d", &packages[i].priority);
        scanf("%f", &packages[i].weight);
        getchar();   // Remove '\n' before reading package message
        fgets(s, 100, stdin);
        s[strchr(s, '\n') - s] = '\0';   // Replace '\n' with string terminator
        packages[i].message = (char *)malloc(strlen(s) + 1);
        strcpy(packages[i].message, s);   // Copy message into the appropriate field
    }
}

void print_request_1(District *districts, Package *packages, int nrDistricts, int nrPackages) {
    int i, j;
    for (i = 0; i < nrDistricts; i++)
        printf("District %d: %s\n", districts[i].id, districts[i].name);
    printf("\n");
    for (i = 0; i < nrPackages; i++) {
        printf("Package %d:\nAddress: ", packages[i].packageId);
        for (j = 0; j < 17; j++)   // Avoid printing a trailing space after the last element
            printf("%d ", packages[i].address[j]);   
        printf("%d\n", packages[i].address[17]);   // Print the last element with '\n'
        printf("Priority: %d    Weight: %.3f\n", packages[i].priority, packages[i].weight);
        printf("Message: %s\n\n", packages[i].message);
    }   
}

int two_to_the_power(int n) {
    int result = 1, i;
    for (i = 1; i <= n; i++)
        result *= 2;
    return result;
}

void extract_address(Package *package) {  
    int i;
    // Initialise fields
    package->districtId = 0;
    package->street = 0;
    package->number = 0;

    // First five elements give the district ID
    for (i = 0; i < 5; i++)
        if (package->address[i])
            package->districtId += two_to_the_power(4 - i);

    // Next five elements give the street number
    for (i = 5; i < 10; i++)
        if (package->address[i])
            package->street += two_to_the_power(9 - i);

    // Last eight elements give the house number    
    for (i = 10; i < 18; i++)
        if (package->address[i])
            package->number += two_to_the_power(17 - i);
}

void print_request_2(Package *packages, int nrPackages) {
    int i;
    for (i = 0; i < nrPackages; i++) {
        printf("Package %d:\n", packages[i].packageId);
        printf("District ID: %d ", packages[i].districtId);
        printf("Street: %d ", packages[i].street);
        printf("Number: %d\n", packages[i].number);
    }
}

void distribute_packages(Postman *postmen, Package *packages, int nrDistricts, int nrPackages) {
    int i, id, n;
    for (i = 0; i < nrDistricts; i++) {
        postmen[i].packageCount = 0;   // Initialize the number of packages for the current postman
        postmen[i].postmanId = i;   // Automatically assign the postman ID
    }
    for (i = 0; i < nrPackages; i++) {
        id = packages[i].districtId;   // Store the district ID associated with the current package
        n = postmen[id].packageCount;   // Store the number of packages assigned so far
        // Use variable n to access the next available position in the array  
        postmen[id].packages[n] = packages[i];   // Add the current package
        // Update the number of packages after adding
        postmen[id].packageCount = postmen[id].packageCount + 1;
    }
}

void print_request_3(Postman *postmen, int nrDistricts) {
    int i, j;
    for (i = 0; i < nrDistricts; i++) {
        printf("Postman %d: %d packages\n", postmen[i].postmanId, postmen[i].packageCount);
        if (postmen[i].packageCount) {   // Display only for postmen with packages
            for (j = 0; j < postmen[i].packageCount - 1; j++)
                printf("Package %d ", postmen[i].packages[j].packageId);
            // Print the last package ID separately to avoid extra whitespace
            printf("%d\n", postmen[i].packages[j].packageId);
        }
    }
}

void swap_packages(Package *a, Package *b) {
    Package aux = *a;
    *a = *b;
    *b = aux;
}

void sort_packages(Package *packages, int n) {
    int i, sorted = 0;
    while (!sorted) {
        sorted = 1;   // Assume the packages are sorted
        for (i = 0; i < n - 1; i++) {
            // First check the priority
            if (packages[i].priority < packages[i + 1].priority) {
                swap_packages(&packages[i], &packages[i + 1]);
                sorted = 0;
            } 
            else if (packages[i].priority == packages[i + 1].priority) {
                // Check the weight
                if (packages[i].weight < packages[i + 1].weight) {
                    swap_packages(&packages[i], &packages[i + 1]);
                    sorted = 0;
                }
            }
        }
    }    
}

char* modify_message(char *s) {
    char word[100], separators[] = ".,?!: ";
    char *encoded = (char *)malloc(100 * sizeof(char));
    int i, j = 0, k, pos = 0;

    // Traverse the original string in reverse order
    for (i = strlen(s) - 1; i >= 0; i--) {
        // Check for a separator
        if (!strchr(separators, s[i]))
            word[j++] = s[i];  // Add letters of a word in reverse order
        else if (j) {   // Exclude the case where the word is empty
            word[j] = '\0';   // Add string terminator
            // Traverse the word in reverse to get the correct order of letters
            for (k = j - 1; k >= 0; k--)   
                encoded[pos++] = word[k];
            j = 0;   // Reset j to prepare for the next word
        }
    }
    
    if (j) {   // Check if there's a final word to add
        // Copy the final word similarly
        word[j] = '\0';
        for (k = j - 1; k >= 0; k--)
            encoded[pos++] = word[k];
    }
    
    encoded[pos] = '\0';   // Add string terminator, the encoded message is ready
    return encoded;
}

int calculate_code(Package *package) {
    int code = 0, i;
    for (i = 0; i < strlen(package->message); i++)
        // Character + 0 in ASCII for conversion instead of atoi function
        code += ('\0' + package->message[i]) * i;
    return code % (package->number * package->street + 1);
}

void print_request_5(Postman *postmen, int nrDistricts) {
    int i, j;
    for (i = 0; i < nrDistricts; i++) {
        printf("Postman %d: %d packages\n", postmen[i].postmanId, postmen[i].packageCount);
        for (j = 0; j < postmen[i].packageCount; j++)
            printf("Package %d: Code %d\n", postmen[i].packages[j].packageId, postmen[i].packages[j].messageCode);
    }
}

int modify_code(int id, int code) {
    int divisor = 2;
    if (id == 0)
        return code ^ 1;   // For id = 0, only the first bit is flipped
    if (id == 1)
        return code ^ (1 << 1);   // For id = 1, only the second bit is flipped
    
    while (id > 1 && divisor < 32) {   // Exclude divisors less than 32
        if (id % divisor == 0) {
            code ^= (1 << divisor);   // Flip the bits at positions equal to prime divisors
            while (id % divisor == 0)
                id /= divisor;    
        }
        divisor++;
    }
    return code;
}

void alter_codes(Package *packages, int nrPackages, int postmanId) {
    int exists = 0, i, digit1, digit2, aux;
    if (postmanId > 9) {   // Both digits need to be retained for searching
        digit1 = postmanId % 10;   
        digit2 = postmanId / 10;
    } else {
        digit1 = postmanId;
        digit2 = 10;   // Symbolic value, will not affect the result in this case
    }

    for (i = 0; i < nrPackages; i++) {
        aux = packages[i].messageCode;
        exists = 0;   // Assume the code does not share any digits with the postman's ID
        while (aux) {
            if (aux % 10 == digit1 || aux % 10 == digit2)
                exists = 1;   // Found a common digit
            aux /= 10;
        }

        if (exists)   // The code needs to be modified
            packages[i].messageCode = modify_code(packages[i].districtId, packages[i].messageCode);
    }
}

void assign_score(Postman *postmen, int nrDistricts) {
    int i, j, k, codes[50];
    float correct;
    for (i = 0; i < nrDistricts; i++) {
        if (postmen[i].packageCount == 0)   // Special case: score is 0
            printf("%d 0.000\n", postmen[i].postmanId);
        else {
            correct = 0;   // Assume all packages are incorrect
            // Copy initial codes
            for (j = 0, k = 0; j < postmen[i].packageCount; j++)
                codes[k++] = postmen[i].packages[j].messageCode;
            
            // Alter the codes
            alter_codes(postmen[i].packages, postmen[i].packageCount, postmen[i].postmanId);
            
            // Compare to see the changes
            for (j = 0; j < postmen[i].packageCount; j++) {
                if (postmen[i].packages[j].messageCode == codes[j])
                    correct++;
            }
            printf("%d %.3f\n", postmen[i].postmanId, correct / postmen[i].packageCount);
        }
    }
}

int main(){
    int nrDistricts, nrPackages, request, i, j;
    /* According to the problem statement, there are a maximum of 32 districts, 
       32 postmen, and 50 packages per postman */
    District districts[32];  
    Package packages[50 * 32];    
    Postman postmen[32];

    // Reading the first value (request type)
    scanf("%d", &request);

    read(districts, packages, &nrDistricts, &nrPackages);  // Reading input

    // Call the functions as needed, following the request type
    for(i = 0; i < nrDistricts; i++)
        extract_address(packages + i);  // Extracting the address of all packages

    distribute_packages(postmen, packages, nrDistricts, nrPackages);  // Distribute all packages

    switch(request){
        case 1:
            print_request_1(districts, packages, nrDistricts, nrPackages);
            break;
        case 2:
            print_request_2(packages, nrDistricts);
            break;
        case 3:
            print_request_3(postmen, nrDistricts);
            break;
        case 4:
            for(i = 0; i < nrDistricts; i++)
                sort_packages(postmen[i].packages, postmen[i].packageCount);  // Sort packages
            print_request_3(postmen, nrDistricts);
            break;
        case 5: 
            for(i = 0; i < nrDistricts; i++){   // Sort first
                sort_packages(postmen[i].packages, postmen[i].packageCount);
                // Calculate codes
                for(j = 0; j < postmen[i].packageCount; j++){
                    postmen[i].packages[j].message = modify_message(postmen[i].packages[j].message);
                    postmen[i].packages[j].messageCode = calculate_code(&postmen[i].packages[j]);
                }
            }
            print_request_5(postmen, nrDistricts);
            break;
        case 6:
            for(i = 0; i < nrDistricts; i++){   // Sort first
                sort_packages(postmen[i].packages, postmen[i].packageCount);
                // Calculate codes
                for(j = 0; j < postmen[i].packageCount; j++){
                    postmen[i].packages[j].message = modify_message(postmen[i].packages[j].message);
                    postmen[i].packages[j].messageCode = calculate_code(&postmen[i].packages[j]);
                }
                // Alter codes
                alter_codes(postmen[i].packages, postmen[i].packageCount, postmen[i].postmanId);
            }
            print_request_5(postmen, nrDistricts);
            break;
        case 7:
            for(i = 0; i < nrDistricts; i++){   // Sort first
                sort_packages(postmen[i].packages, postmen[i].packageCount);
                // Calculate codes
                for(j = 0; j < postmen[i].packageCount; j++){
                    postmen[i].packages[j].message = modify_message(postmen[i].packages[j].message);
                    postmen[i].packages[j].messageCode = calculate_code(&postmen[i].packages[j]);
                }
            }
            // Alteration done in assign_score function
            assign_score(postmen, nrDistricts);
            break;
    } 

    return 0;
}